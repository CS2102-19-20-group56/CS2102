import React, { Component } from 'react';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';


export class ViewOrderTable extends Component {

    render() {
        if (!this.props.showTable) {
            return <div></div>
        }
        if (this.props.loading) {
            return (
                <div>Loading...</div>
            );
        } else {
            const { data, header } = this.props;
            return (
                <TableContainer component={Paper}>

                    <Table>
                        <TableHead>
                            <TableRow>
                                {header.map((x) =>
                                    <TableCell>
                                        {x.name}
                                    </TableCell>
                                )}
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {data.map((row) => (
                                <TableRow key={row["orderid"]}>
                                    <TableCell component="th" scope="row">
                                        {row["orderid"]}
                                    </TableCell>
                                    <TableCell>{new Date(row["departtimeforrestaurant"]).toLocaleString('en-US')}</TableCell>
                                    <TableCell>{new Date(row["deliverytimetocustomer"]).toLocaleString('en-US')}</TableCell>
                                    <TableCell>{row["rating"]}</TableCell>
                                    <TableCell>{row["delivery_fee"]}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
            );
        }
    }
}

export default ViewOrderTable