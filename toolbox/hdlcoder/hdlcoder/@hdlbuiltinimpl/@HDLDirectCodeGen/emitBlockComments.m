function hdlcode=emitBlockComments(this,hC)





    hdlcode=hdlcodeinit;

    bfp=hC.SimulinkHandle;

    if bfp>0
        desc=get_param(bfp,'Description');
        if~isempty(desc)
            hdlcode.arch_body_blocks=hdlformatcomment(desc,2);
        end
    end
