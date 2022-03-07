pragma circom 2.0.0;

include "mimcsponge.circom";

template merkle_root(n) {
    signal input leaves[n];
    signal output root;

    var totalLeaves[2*n-1];
    component sponge[n-1];

    /* Hash leaves and store */
    for (var i = 0; i < n; i++) {
        totalLeaves[i] = leaves[i];
    }

    /* Hash upper levels */
    for (var i = 0; i < n - 1; i++) {
        sponge[i] = MiMCSponge(2, 220, 1);
        sponge[i].k <== 0;
        sponge[i].ins[0] <== totalLeaves[2*i];
        sponge[i].ins[1] <== totalLeaves[2*i+1];
        totalLeaves[i+n] = sponge[i].outs[0];
    }

    root <== totalLeaves[2*n-2];

}

component main{public [leaves]} = merkle_root(4);
