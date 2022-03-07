pragma circom 2.0.0;

include "mimcsponge.circom";

template merkle_root(n) {
    signal input leaves[n];
    signal output root;

    var comp[2*n-1];
    component mimc[n-1];

    /* Hashes the first leaves and stores it on comp */
    for (var i = 0; i < n; i++) {
        comp[i] = leaves[i];
    }

    /* Hashes each pair of leaves and upper levels */
    for (var i = 0; i < n - 1; i++) {
        mimc[i] = MiMCSponge(2, 220, 1);
        mimc[i].k <== 0;
        mimc[i].ins[0] <== comp[2*i];
        mimc[i].ins[1] <== comp[2*i+1];
        comp[i+n] = mimc[i].outs[0];
    }

    root <== comp[2*n-2];

}

component main{public [leaves]} = merkle_root(4);
