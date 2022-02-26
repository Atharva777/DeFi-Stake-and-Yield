import { useEthers } from "@usedapp/core"
import helperConfig from "../helper-config.json"
import networkMapping from "../chain-info/deployments/map.json"
import brownieConfig from "../brownie-config.json"
import { constants, ethers } from "ethers"
import { YourWallet } from "./yourWallet/YourWallet"
import dapp from "../dapp.png"
import eth from "../eth.png"
import dai from "../dai.png"
import bat from "../bat.png"
import { makeStyles } from "@material-ui/core"


export type Token = {
    image: string
    address: string
    name: string
}

const useStyles = makeStyles((theme) => ({
    title: {
        color: theme.palette.common.white,
        textAlign: "center",
        padding: theme.spacing(4)
    }
}))

export const Main = () => {
    //Show token values from the wallet
    //Get the address of the different tokens
    // Get the balance of the user tokens
    //Send the brownie-config to source 'src' folder
    //Send the build folder
    const classes = useStyles()
    const {chainId } = useEthers()
    const networkName = chainId ? helperConfig[chainId] : "dev"

    const dappTokenAddress = chainId ? networkMapping[String(chainId)]["DappToken"][0]: constants.AddressZero
    const wethTokenAddress = chainId ? brownieConfig["networks"][networkName]["weth_token"] : constants.AddressZero
    const fauTokenAddress = chainId ? brownieConfig["networks"][networkName]["fau_token"] : constants.AddressZero
    const batTokenAddress = chainId ? brownieConfig["networks"][networkName]["bat_token"] : constants.AddressZero

    const supportedTokens: Array<Token>= [
        {
            image: dapp,
            address: dappTokenAddress,
            name:"DAPP" },
            {
                image: eth,
                address: wethTokenAddress,
                name: "WETH"
            },
            {
                image: dai,
                address: fauTokenAddress,
                name: "DAI"
            },
            {
                image: bat,
                address: batTokenAddress,
                name: "BAT" 
            }
    ]

    

    return (<><h2 className={classes.title}>Dapp Token App</h2><YourWallet supportedTokens = {supportedTokens} /></>)


}