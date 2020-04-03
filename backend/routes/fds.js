var express = require('express');
var router = express.Router();

const pool = require('../database/db');

//8. averaged rating received by rider for orders delivered that month
router.get('/getMonthlyAvgRating', async (req,res)=> {
    const month = req.body.month;
    const query = `SELECT round(sum(rating)::numeric/count(rating),2) as avgRating ,userId
	FROM Delivers D
	WHERE DATE_PART('MONTHS',D.deliveryTimetoCustomer) = ${month}
	GROUP BY userId
	;`
    pool.query(query).then(result => {
        let avgRating = (result.rows);
        console.log('num of ratings:', avgRating);
        res.json(avgRating);
    }).catch(err => {
        if (err.constraint) {
            console.error(err.constraint);
        } else {
            console.log(err);
            res.json(err);
        }
    });

})

//7. number of ratings received by rider for all orders delivered for that month
router.get('/getMonthlyNumRating', async (req,res)=> {
    const month = req.body.month;
    const query = `SELECT count(rating) as numRating, userId
	FROM Delivers D
	WHERE DATE_PART('MONTHS',D.deliveryTimetoCustomer) = ${month}
	GROUP BY userId
	;`
    pool.query(query).then(result => {
        let numRating =  result.rows
        console.log('num of ratings:', numRating);
        res.json(numRating);
    }).catch(err => {
        if (err.constraint) {
            console.error(err.constraint);
        } else {
            console.log(err);
            res.json(err);
        }
    });

})

// 6. average delivery time by the rider for that month
//departTimeForRestaurant - deliveryTimetoCustomer = delivery time
// average delivery time = total delivery time / total num of orders [monthly]
router.get('/getMonthlyAverageDeliveryTime', async (req,res)=>{
    const month = req.body.month;
    const query = `select sum((extract(epoch from (deliveryTimetoCustomer - departTimeForRestaurant)))/60)
		/count(userId) as avgTime, userId
		FROM Delivers D
		WHERE DATE_PART('months',D.deliveryTimetoCustomer) = ${month}
		GROUP BY userId`
    pool.query(query).then(result => {
            let avgTime = result.rows
            console.log('result:', avgTime);
            res.json(avgTime);
    }).catch(err => {
        if (err.constraint) {
            console.error(err.constraint);
        } else {
            console.log(err);
            res.json(err);
        }
    });

})

// not tested yet
router.get('/checkStatus', async (req, res) => {
    const timeArr = ["10:00:00", "11:00:00", "12:00:00", "13:00:00", "14:00:00"
    , "15:00:00", "16:00:00", "17:00:00", "18:00:00", "19:00:00", "20:00:00",
    "21:00:00", "22:00:00"]
    const day = req.body.day; //example 2020-11-12
    let querytime = 0;
    const query = `SELECT sum(R.userId)
    FROM Riders R
    WHERE checkWorkingStatusHelperOfRider(R.userId, ${querytime}) = 1;`

    let result = [];

    for(let i = 0; i < timeArr.length; i++) {
        querytime = day + " " + timeArr[i];
        pool.query(query).then(result => {
            let noOfriders = result.rows
            console.log(result.rows)
            result.push(result.rows[0].sum);
    }).catch(err => {
        if (err.constraint) {
            console.error(err.constraint);
        } else {
            console.log(err);
            res.json(err);
        }
    });
    }
    res.json(result);
})

module.exports = router;
