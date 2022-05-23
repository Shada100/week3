// [bonus] implement an example game from part d
pragma circom 2.0.0;
include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
template RangeProof(n) {
    assert(n <= 252);
    signal input in; // this is the number to be proved inside the range
    signal input range[2]; // the two elements should be the range, i.e. [lower bound, upper bound]
    signal output out;

    component low = LessEqThan(n);
    component high = GreaterEqThan(n);
    // Checking if it is less than the upper bound
    low.in[0] <== in;
    low.in[1] <== range[1];
    1 === low.out;
    //checking if it is higher than the upperbound
    high.in[0] <== in;
    high.in[1] <== range[0];
    1 === high.out;
    //this is like an And truth table will give an output of one 
    //only if both are with(within range)
    out <== (low.out) * (high.out);
}
template Ensureboardlimitandifbombed() {
    //public input 
    //escapers coordinate on the x axis 
    signal input escapersGuessX;
    //escapers coordinate on the y axis 
    signal input escapersGuessY;
    //bombers hashed and salted position and range picked
    signal input hashedBomberXY;
    //the range of the bomb picked
    signal input bombRange;
    //private input
    //bombs coordinate on the x axis 
    signal input bombX;
    //bombs coordinate on the y axis
    signal input bombY;
    //private salt
    signal input privSalt;
   

    signal output solHashOut;


    var Ecoordinate[2] = [escapersGuessX, escapersGuessY];
    var Bcoordinate[2] = [bombX, bombY];
    component lessThan[4];

    //Creating a constraint that the x and y position chosen by
    // the bomber and escaper to ensure is on the board
    for(var i = 0; i < 2; i++){
        lessThan[i] = LessThan(4);
        lessThan[i].in[0] <== Ecoordinate[i];
        lessThan[i].in[1] <== 10;
        lessThan[i].out === 1;
        lessThan[i+2] = LessThan(4);
        lessThan[i+2].in[0] <== Bcoordinate[i];
        lessThan[i+2].in[1] <== 10;
        lessThan[i+2].out === 1;
    }
    //checking if the escaper falls in between the bombers range
    component Rang[2];
    var bombed = 0;
    var escaped = 0;

    //checking the attackers x coordinate with the bombers x range 
    Rang[0] = RangeProof(5);
    Rang[0].in <==  Ecoordinate[0];
    Rang[0].range[0] <== bombX-bombRange;
    Rang[0].range[1] <== bombX+bombRange;
    //checking the attackers y coordinate with the bombers y range
    Rang[1] = RangeProof(5);
    Rang[1].in <==  Ecoordinate[1];
    Rang[1].range[0] <== bombY-bombRange;
    Rang[1].range[1] <== bombY+bombRange;
    // if the output is both 1 meaning the escaper is within the bombers range of distruction gets a point
    if (Rang[0].out == 1 && Rang[1].out == 1 ){
        bombed += 1;
        //Accurate bomber 
        if (Ecoordinate[0] == bombX && Ecoordinate[1] == bombY){
            bombed += 1;
        }
        }
    // else any other output 0 1, 1 0 and 0 0 would mean the escaper is not within the bombs range 
    else{
        escaped += 1;
    }


    //This will hash the bombers current x y and privsalt and compare it ith what was commited at the beginning of the round
    component poseidon = Poseidon(3);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== bombX;
    poseidon.inputs[2] <== bombY;
  

    solHashOut <== poseidon.out;
    hashedBomberXY === solHashOut;

}
component main{public[escapersGuessX, escapersGuessY, hashedBomberXY, bombRange]} =  Ensureboardlimitandifbombed();