// [bonus] unit test for bonus.circom
const chai = require("chai");
const path = require("path");
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const wasm_tester = require("circom_tester").wasm;

const assert = chai.assert;

const {buildPoseidon} = require("circomlibjs");


describe("bonus test", function ()  {
    this.timeout(10000000);

    it("it should give true for correct input", async() =>{
        let poseidonJ = await buildPoseidon();
        let P = poseidonJ.F;
        const circuit = await wasm_tester("contracts/circuits/bonus.circom");
        await circuit.loadConstraints(); 
        let Ecoordinate = [5, 7];
        let Bcoordinate = [4, 6];
       
        const privSalt = "1299488392";
        const toHash = [privSalt, ...Bcoordinate];
        let hashedBomberXY = poseidonJ(toHash)

        
       
        
        const INPUT = {"escapersGuessX" : "5", "escapersGuessY" : "5", 
                        "hashedBomberXY" : P.toObject(hashedBomberXY), "bombRange" : "3",
                        "bombX" : "4", "bombY" : "6", "privSalt" : privSalt
        }
        
       let witness = await circuit.calculateWitness(INPUT, true );
       await circuit.checkConstraints(witness);
       await circuit.assertOut(witness, {solHashOut: P.toObject(hashedBomberXY)} );

    })
})
    