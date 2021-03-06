import React from "react";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import Typography from "@material-ui/core/Grid";
import Grid from "@material-ui/core/Grid";
import Button from '@material-ui/core/Button';
import Container from '@material-ui/core/Container';
import TextField from '@material-ui/core/TextField';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import MenuItem from '@material-ui/core/MenuItem';
import InputLabel from '@material-ui/core/InputLabel';
import OutlinedInput from "@material-ui/core/OutlinedInput";


class Login extends React.Component {
    state = {
        newOrExistingUser: "unknown",
        userId: null,
        userType: null,
        userName: null,
        dataFetched: false,
        creditcardinfo: null,
        area: null,
        partTimeOrFullTime: null,
        rname: "",
        allRname: [],
    }
    componentDidMount() {
        this.getAllRname();
    }
    getAllRname = () => {
        fetch(`http://localhost:5000/general/getAllRname`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            }
        })
            .then(res => res.json())
            .then(json => {
                this.setState({ allRname: json })
                console.log("all rname:", this.state.allRname);
            })
            .catch(err => err);
    }
    setExistingUser = () => {
        this.setState({ newOrExistingUser: "existing" });
    }

    setNewUser = () => {
        this.setState({ newOrExistingUser: "new" });
    }

    handleChange = (event) => {
        const { name, value } = event.target;
        return this.setState({ [name]: value });
    }
    handleLogin = () => {
        const userId = this.state.userId;
        fetch(`http://localhost:5000/general/getUserType?userId=${this.state.userId}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            }
        })
            .then(res => res.json())
            .then(json => {
                this.setState({ userType: json }, this.handleRedirect)
            })
            .catch(err => err);
    }

    handleCreateAccount = () => {
        const userType = this.state.userType;
        switch (userType) {
            case "customer":
                fetch(`http://localhost:5000/customer/insertCustomer`, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        name: this.state.userName,
                        creditcardinfo: this.state.creditcardinfo
                    })
                })
                    .then(res => res.json())
                    .then(json => {
                        this.setState({ userType: "customer", userId: json }, this.handleRedirect)
                    })
                    .catch(err => err);
                break;
            case "rider":
                if (this.state.partTimeOrFullTime === "partTime") {
                    fetch(`http://localhost:5000/rider/insertPartTimeRider`, {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            name: this.state.userName,
                            area: this.state.area
                        })
                    })
                        .then(res => res.json())
                        .then(json => {
                            this.setState({ userType: "rider" }, this.handleRedirect)
                        })
                        .catch(err => err);
                    break;
                } else if (this.state.partTimeOrFullTime === "fullTime") {
                    fetch(`http://localhost:5000/rider/insertFullTimeRider`, {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            name: this.state.userName,
                            area: this.state.area
                        })
                    })
                        .then(res => res.json())
                        .then(json => {
                            this.setState({ userType: "rider" }, this.handleRedirect)
                        })
                        .catch(err => err);
                    break;
                }
            case "FM":
                fetch(`http://localhost:5000/fds/insertFDS`, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        name: this.state.userName,
                    })
                })
                    .then(res => res.json())
                    .then(json => {
                        this.setState({ userType: "FM", userId: json }, this.handleRedirect)
                    })
                    .catch(err => err);
                break;
            case "RS":
                fetch(`http://localhost:5000/rs/insertRS`, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        name: this.state.userName,
                        rname: this.state.rname
                    })
                })
                    .then(res => res.json())
                    .then(json => {
                        this.setState({ userType: "RS", userId: json }, this.handleRedirect)
                    })
                    .catch(err => err);
                break;
            default:
                return null;
        }
    }

    handleRedirect = () => {
        let userType = this.state.userType;
        switch (this.state.userType) {
            case "customer":
                this.props.history.push({
                    pathname: '/customerActions',
                    state:
                    {
                        userId: this.state.userId,
                        userType: userType
                    }
                });
                break;
            case "rider":
                this.props.history.push({
                    pathname: '/Rider',
                    state:
                    {
                        userId: this.state.userId,
                        userType: userType
                    }
                });
                break;
            case "RS":
                this.props.history.push({
                    pathname: '/RestaurantStaff',
                    state:
                    {
                        userId: this.state.userId,
                        userType: userType
                    }
                });
                break;
            case "FM":
                this.props.history.push({
                    pathname: '/FDSManager',
                    state:
                    {
                        userId: this.state.userId,
                    }
                });
                break;
            default:
        }
    }
    // checkUserType = () => {
    //     console.log(this.state.userType == "customer");
    //     return this.state.userType !== null;
    // }


    existingUserInput =
        <Grid container spacing={2} direction="row" justify="center" alignItems="center">
            <Grid item style={{ width: "100%" }}>
                <TextField
                    required
                    name="userId"
                    label="Required"
                    helperText="Enter your User ID"
                    placeholder="User ID"
                    variant="outlined"
                    value={this.state.userId}
                    onChange={this.handleChange}
                />
            </Grid>
            <Grid item style={{ width: "100%" }}>
                <Button variant="contained" color="primary" onClick={this.handleLogin}>
                    Login
                </Button>
            </Grid>
        </Grid>
        ;


    render() {
        return (
            <React.Fragment>
                <AppBar position="relative">
                    <Toolbar>
                        <Typography variant="h6" color="inherit" noWrap>
                            Food Delivery Service
                        </Typography>
                    </Toolbar>
                </AppBar>
                <Container maxWidth="sm">
                    <Typography component="h1" variant="h2" align="center" color="textPrimary" gutterBottom>
                        WELCOME
                    </Typography>
                    <Typography variant="h5" align="center" color="textSecondary" paragraph>
                        Our very own Food Delivery Service created by Chee Ping, Ee Jian, Wei Dong & Jit Yong
                    </Typography>
                    <div>
                        <br /> <br />
                        <Grid container spacing={2} direction="column" justify="center" alignItems="center">
                            <Grid item>
                                <Button variant="contained" color="primary" onClick={this.setExistingUser}>
                                    Existing user? Login here!
                                </Button>
                            </Grid>
                            <Grid item>
                                {this.state.newOrExistingUser === "existing" ? this.existingUserInput : null}
                            </Grid>
                            <Grid item>
                                <Button variant="outlined" color="secondary" onClick={this.setNewUser}>
                                    New user? Create an account!
                                </Button>
                            </Grid>
                            <Grid item>
                                {this.state.newOrExistingUser === "new" &&
                                    <Grid container spacing={2} direction="column" justify="center" alignItems="flex-start">
                                        <Grid item style={{ width: "100%" }}>
                                            <FormControl variant="outlined" style={{ width: "100%" }}>
                                                <InputLabel>User Type</InputLabel>
                                                <Select
                                                    required
                                                    name="userType"
                                                    value={this.state.userType}
                                                    onChange={this.handleChange}
                                                    input={
                                                        <OutlinedInput
                                                            label="User Type"
                                                            name="userType"
                                                            id="userType"
                                                        />
                                                    }
                                                >
                                                    <MenuItem value=""> --- Please select one ---</MenuItem>
                                                    <MenuItem value="customer">Customer</MenuItem>
                                                    <MenuItem value="rider">Rider</MenuItem>
                                                    <MenuItem value="RS">Restaurant Staff</MenuItem>
                                                    <MenuItem value="FM">FDS Manager</MenuItem>
                                                </Select>
                                            </FormControl>
                                        </Grid>
                                        <Grid item style={{ width: "100%" }}>
                                            <TextField
                                                name="userName"
                                                label="Enter User Name"
                                                placeholder="User Name"
                                                variant="outlined"
                                                value={this.state.userName}
                                                onChange={this.handleChange}
                                            />
                                        </Grid>
                                        {this.state.userType === "rider" &&
                                            <React.Fragment>
                                                <Grid item style={{ width: "100%" }}>
                                                    <FormControl variant="outlined" style={{ width: "100%" }}>
                                                        <InputLabel>Delivery Area</InputLabel>
                                                        <Select
                                                            required
                                                            name="area"
                                                            value={this.state.area}
                                                            onChange={this.handleChange}
                                                            input={
                                                                <OutlinedInput
                                                                    label="area"
                                                                    name="area"
                                                                    id="area"
                                                                />
                                                            }
                                                        >
                                                            <MenuItem value=""> --- Please select one ---</MenuItem>
                                                            <MenuItem value="north">North</MenuItem>
                                                            <MenuItem value="south">South</MenuItem>
                                                            <MenuItem value="east">East</MenuItem>
                                                            <MenuItem value="west">West</MenuItem>
                                                        </Select>
                                                    </FormControl>
                                                </Grid>
                                                <Grid item style={{ width: "100%" }}>
                                                    <FormControl variant="outlined" style={{ width: "100%" }}>
                                                        <InputLabel>Schedule Type</InputLabel>
                                                        <Select
                                                            required
                                                            name="partTimeOrFullTime"
                                                            value={this.state.partTimeOrFullTime}
                                                            onChange={this.handleChange}
                                                            input={
                                                                <OutlinedInput
                                                                    label="partTimeOrFullTime"
                                                                    name="partTimeOrFullTime"
                                                                    id="partTimeOrFullTime"
                                                                />
                                                            }
                                                        >
                                                            <MenuItem value=""> --- Please select one ---</MenuItem>
                                                            <MenuItem value="partTime">Part Time</MenuItem>
                                                            <MenuItem value="fullTime">Full Time</MenuItem>
                                                        </Select>
                                                    </FormControl>
                                                </Grid>
                                            </React.Fragment>
                                        }
                                        {this.state.userType === "customer" &&
                                            <Grid item style={{ width: "100%" }}>
                                                <TextField
                                                    required
                                                    name="creditCardInfo"
                                                    label="Credit Card Information"
                                                    placeholder="Credit Card Information"
                                                    helperText="Optional"
                                                    variant="outlined"
                                                    value={this.state.creditcardinfo}
                                                    onChange={this.handleChange}
                                                />
                                            </Grid>
                                        }
                                        {this.state.userType === "RS" &&
                                        <Grid item style={{ width: "100%" }}>
                                            <FormControl variant="outlined" style={{ width: "100%" }}>
                                                <InputLabel>Restaurant Name</InputLabel>
                                                <Select
                                                    required
                                                    name="rname"
                                                    value={this.state.rname}
                                                    onChange={this.handleChange}

                                                >
                                                    {this.state.allRname.map(res => {
                                                        return (
                                                            <MenuItem value={res.rname}>{res.rname}</MenuItem>
                                                        )
                                                    })}
                                                </Select>
                                            </FormControl>
                                        </Grid>
                                        }
                                        <Grid item>
                                            <Button variant="contained" color="secondary"
                                                onClick={this.handleCreateAccount}>
                                                Create Account
                                        </Button>
                                        </Grid>
                                    </Grid>
                                }
                            </Grid>
                        </Grid>
                    </div>
                </Container>
            </React.Fragment>

        );
    }
}

export default Login;
