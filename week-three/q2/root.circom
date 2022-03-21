pragma circom 2.0.0;

include "../circomlib/circuits/mimcsponge.circom";
include "../circomlib/circuits/gates.circom";

template CardCommitment() {
    signal input password;
    signal input number;
    signal input suite;
    
    signal output commitment;

    // hash the values
    component mimc = MiMCSponge(3, 220, 1);
    mimc.ins[0] <== password;
    mimc.ins[1] <== suite;
    mimc.ins[2] <== number;
    mimc.k <== 0;

    commitment <== mimc.outs[0];
}

template CheckSuitesEqual() {
    // inputs for the first card
    signal input first_password;
    signal input first_suite;
    signal input first_number;

    // inputs for the second card
    signal input second_password;
    signal input second_suite;
    signal input second_number;

    signal output first_commitment;
    signal output second_commitment;

    // Verifies first card
    component first_card = CardCommitment();
    first_card.password <== first_password;
    first_card.suite <== first_suite;
    first_card.number <== first_number;
    first_card.commitment ==> first_commitment;

    // Verifies the second card
    component second_card = CardCommitment();
    second_card.password <== second_password;
    second_card.suite <== second_suite;
    second_card.number <== second_number;
    second_card.commitment ==> second_commitment;

    // check if both cards have same suite
    component multi_and_gate = MultiAND(2);
    multi_and_gate.in[0] <== first_suite;
    multi_and_gate.in[1] <== second_suite;
}

component main = CheckSuitesEqual();
