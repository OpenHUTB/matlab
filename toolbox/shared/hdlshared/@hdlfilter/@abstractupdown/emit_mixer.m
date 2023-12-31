function[multbody,mixersignals,mixertempsigs,mixeroutsig]=...
    emit_mixer(this,input1,input2,productsltype,accumsltype)





    mixerrounding='nearest';
    mixersaturation=0;

    ccmult=hdl.spblkmultiply(...
    'in1',input1,...
    'in2',input2,...
    'outname','mixer_out',...
    'product_sltype',productsltype,...
    'accumulator_sltype',accumsltype,...
    'rounding',mixerrounding,...
    'saturation',mixersaturation...
    );

    ccmultcode=ccmult.emit;
    multbody=ccmultcode.arch_body_blocks;
    mixeroutsig=ccmult.out;
    mixersignals=[makehdlsignaldecl(ccmult.out),...
    makehdlsignaldecl(ccmult.re1),...
    makehdlsignaldecl(ccmult.re2),...
    makehdlsignaldecl(ccmult.im1),...
    makehdlsignaldecl(ccmult.im2)];
    mixertempsigs=ccmultcode.arch_signals;


