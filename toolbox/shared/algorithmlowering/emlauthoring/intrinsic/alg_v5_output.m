function[r]=alg_v5_output(state)

%#codegen

    coder.allowpcode('plain');

    tpm32=2.328306436538696e-10;

    ui=eml_plus(state(1),state(2),'uint32','wrap');
    r=double(ui)*tpm32;
