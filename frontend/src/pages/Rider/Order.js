import React, { Component } from 'react';
import { FormViewOrder } from './FormViewOrder';
import { ViewOrderTable } from './ViewOrderTable';
import { ViewOngoingOrder } from './ViewOngoingOrder';


import TextField from '@material-ui/core/TextField';

export class Order extends Component {

    state = {
        data: null,
        loading: false,
        showTable: false,
        ongoingOrder: null,
        orderDetails: [],
        orderedFood: [],
    };
    componentDidMount() {
        this.getOngoingOrder();
    }

    getOngoingOrder = async () => {
       return fetch(`
        http://localhost:5000/rider/getOngoingOrder?userId=${this.props.userId}`,
            {
                method: 'GET',
                headers: {
                    'Accept':
                        'application/json',
                    'Content-Type':
                        'application/json',
                }
            }
        )
            .then(res => res.json())
            .then(json => {
                this.setState({ongoingOrder: json.orderid}, this.getOrderDetails)
                console.log('ongoingOrder', this.state.ongoingOrder)
            })
           .catch(err => err);

    }

    getOrderDetails = async () => {
        return fetch(`
        http://localhost:5000/rider/getOrderDetails?orderId=${this.state.ongoingOrder}`,
            {
                method: 'GET',
                headers: {
                    'Accept':
                        'application/json',
                    'Content-Type':
                        'application/json',
                }
            }
        )
            .then(res => res.json())
            .then(json => {
                this.setState({orderDetails: json}, this.getOrderedFood)
                console.log('orderDetails', this.state.orderDetails)
            })
            .catch(err => err);

    }
    getOrderedFood = async () => {
       return fetch(`
        http://localhost:5000/rider/getOrderedFood?orderId=${this.state.ongoingOrder}`,
            {
                method: 'GET',
                headers: {
                    'Accept':
                        'application/json',
                    'Content-Type':
                        'application/json',
                }
            }
        )
            .then(res => res.json())
            .then(json => {
                this.setState({orderedFood: json})
                console.log('orderedFood', this.state.orderedFood)
            })
           .catch(err => err);

    }

    loadData = async (month, year) => {
        this.setState({
            loading: true,
            showTable: true
        },
            function () { console.log("setState completed") }
        )
        await this.fetchData(month, year);
        this.setState({ loading: false });
    };

    fetchData = async (month, year) => {
        return fetch(`http://localhost:5000/rider/getPastOrder?userId=${this.props.userId}&month=${month}&year=${year}`, {
            method: "GET",
            dataType: "JSON",
            headers: {
                "Accept": "application/json",
                "Content-Type": "application/json; charset=utf-8",
            }
        })
            .then(response => response.json())
            .then(result => {
                this.setState({ data: result })
                console.log(this.state.data);
            });
    };

    render() {
        return (
            <div style={{ "height": "100%" }}>
                <ViewOngoingOrder userId={this.props.userId} orderId={this.state.ongoingOrder}
                                  orderDetails={this.state.orderDetails} orderedFood={this.state.orderedFood}
                                  />
                <FormViewOrder userId={this.props.userId} loadData={this.loadData} />
                <br />
                <ViewOrderTable
                    loading={this.state.loading}
                    data={this.state.data}
                    showTable={this.state.showTable}
                    header={[
                        {
                            name: "Order No.",
                            prop: "orderid"
                        },
                        {
                            name: "Start Delivery",
                            prop: "departtimeforrestaurant"
                        },
                        {
                            name: "End Delivery",
                            prop: "deliverytimetocustomer"
                        },
                        {
                            name: "Rating",
                            prop: "rating"
                        },
                        {
                            name: "Delivery Fee",
                            prop: "delivery_fee"
                        },
                    ]}
                />
            </div>
        )
    }
}

export default Order
