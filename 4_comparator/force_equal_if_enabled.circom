include "iszero.circom";

template ForceEqualIfEnabled() {
    signal input enabled;
    signal input in[2];

    component isz = IsZero();

    in[1] - in[0] ==> isz.in;

    (1 - isz.out)*enabled === 0;
}

// making signals public because a circuit needs at least one of these: and output or a public intput or an output
component main{public[enabled, in]} = ForceEqualIfEnabled();