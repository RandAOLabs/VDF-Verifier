import { readFileSync } from "node:fs";
import { message, result, createDataItemSigner, spawn } from "@permaweb/aoconnect";

// Load the wallet file
const wallet = JSON.parse(readFileSync("./wallet.json").toString(),);
const processId = "wHdeq9xRwIBoNVKrTcnHXnCpEqqlTIzntV1KsQx6yKw"

const request_id                 = "id"
const checkpoint_input          = "0x8ea473939335cbe03ab3586fb611477a1859e144ffa42e524151ea4c5f1948e"
const modulus                   = "0x40e77a538238e49424de6139311eaee7d7f1e31a0e87b2051e1f94bb4b0ad2d"
//const expected_output           = "0x2888fbced9adbafdda5b31e515a8c984f5d6180b7cf27ebe548b6f62f24c787"
const segment_id                 = "id"

const input = "0x8ea473939335cbe03ab3586fb611477a1859e144ffa42e524151ea4c5f1948e"
const expected_output = "2604593209"
async function validateOutput() {
    let tags = [
        { name: "Action", value: "Validate-Output" },
    ]

    let id = await message({
        /*-+
          The arweave TXID of the process, this will become the "target".
          This is the process the message is ultimately sent to.
        */
        process: processId,
        // Tags that the process will use as input.
        tags,
        // A signer function used to build the message "signature"
        signer: createDataItemSigner(wallet),
        /*
          The "data" portion of the message
          If not specified a random string will be generated
        */
        data: JSON.stringify({ request_id, segment_id, input, expected_output }),
    })

    console.log(id)
    const { Output, Messages } = await result({
        message: id,
        process: processId,
    });
    
    if (Messages && Messages.length > 0) {
        const data = JSON.parse(Messages[0].Data);
        console.log("Status: ", data);
    }
    
    return id;
}

async function validate() {
    let tags = [
        { name: "Action", value: "Validate-Checkpoint" },
    ]

    let id = await message({
        /*-+
          The arweave TXID of the process, this will become the "target".
          This is the process the message is ultimately sent to.
        */
        process: processId,
        // Tags that the process will use as input.
        tags,
        // A signer function used to build the message "signature"
        signer: createDataItemSigner(wallet),
        /*
          The "data" portion of the message
          If not specified a random string will be generated
        */
        data: JSON.stringify({ request_id, segment_id, checkpoint_input, modulus, expected_output }),
    })

    console.log(id)
    const { Output, Messages } = await result({
        message: id,
        process: processId,
    });
    
    if (Messages && Messages.length > 0) {
        const data = JSON.parse(Messages[0].Data);
        console.log("Status: ", data);
    }
    
    return id;
}

// Main function to call post data
async function main() {
    const inputArg =  process.argv[2];
    
    if (inputArg == 1) {
        try {
            await validate()
        } catch (err) {
            console.error("Error reading process IDs or sending messages:", err);
        }
    } 
    if (inputArg == 2) {
        try {
            await validateOutput()
        } catch (err) {
            console.error("Error reading process IDs or sending messages:", err);
        }
    } 
}

main();