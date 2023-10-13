function[z,p,k]=fos2zpk(b,a)

%#codegen

    coder.inline('never');
    coder.allowpcode('plain');

    [z,p,k]=signal.internal.filterdesignutils.fos2zpk(b,a);