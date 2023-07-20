function[num,den]=zpk2sos(z,p,k)





%#codegen

    coder.inline('never');
    coder.allowpcode('plain');

    [num,den]=signal.internal.filterdesignutils.zpk2sos(z,p,k);