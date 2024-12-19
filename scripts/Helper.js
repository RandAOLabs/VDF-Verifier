import { readFileSync } from "node:fs";
import { message, result, createDataItemSigner, spawn } from "@permaweb/aoconnect";

// Load the wallet file
const wallet = JSON.parse(readFileSync("./wallet.json").toString(),);
const processId = "ZLBhaNQskckeoyN_Qvzrdv-39pAqe_UGhb_FwzoX7FM"

const request_id                 = "id"
const checkpoint_input          = "0xdfc9eb0241f850538995dd0623a96ec3a41a8d335baea49efb14a328ef2dc5ca3579077f42e224485df21763bac99901fba62090927b8bde335be427d049a32e"
const modulus                   = "0x219c1bc686e52bf711ef3ca081ad910a5cd42deb5e4ddd0ab4a4025e899f029276b519241634765ebd7a445a1066759017c6495fe8c2782921f4a675a248d2719c41f6ebc703179e18bea6a07b08adcc90f06d06ba7d4542a97ae8dd66812000907fb3e9fbb61a287d6775c51b050ace1606f0e140e3b0387e13d6e8631d8773"
const expected_output           = "0x6e7405967439466d3685eb22acf1dc1d6dda9784b049796bb35b90f0fb2401f2d4dd85bf7b955143c70c22e5e9903f4154dae3de2aa25cadf24e7393c14d4a238c242b545c9ff0523f80407994b2f007673d6ecdceb6e02473ad30218b2a29095da8fb7b9014c1f2b949d020357e2e4469a886f86d1842c8e385ead6a44887c"
const segment_id                 = "id"

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
}

main();