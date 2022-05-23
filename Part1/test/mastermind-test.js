//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected
const chai = require("chai");
const path = require("path");
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

const {buildPoseidon} = require("circomlibjs");


describe("Matermind test", function ()  {
    this.timeout(10000000);
    

    
    it("it should give true for correct input", async() =>{
        let poseidonJ = await buildPoseidon();
        let P = poseidonJ.F;
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();
       
        let soln = [3, 5, 1];
        let guess = [3, 5, 1];
        let hit = 0;
        let blow = 0;
        const privSalt = "1299488392";
        const toHash = [privSalt, ...guess];
        let pubSolnHash = poseidonJ(toHash)

        for(var i = 0; i < 3; i++){
            for( var j = 0; j < 3; j++){
              blow +=  (soln[i] == guess[j]) ? 1 : 0;
                if (i == j){
                    hit +=  (soln[i] == guess[j]) ? 1 : 0;
                    blow -=  (soln[i] == guess[j]) ? 1 : 0;
                }
            }
        }
       
        
        const INPUT = {"pubGuessA" : "3", "pubGuessB" : "5", "pubGuessC" : "1", "pubNumHit" : "3",
                        "pubNumBlow" : "0",
                        "privSalt" : privSalt,
                        "pubSolnHash" : P.toObject(pubSolnHash),
                        "privSolnA" : "3", "privSolnB" : "5", "privSolnC" : "1"
        }
        
       let witness = await circuit.calculateWitness(INPUT, true );
       await circuit.checkConstraints(witness);
       await circuit.assertOut(witness, {solnHashOut: P.toObject(pubSolnHash)} );

    })
})