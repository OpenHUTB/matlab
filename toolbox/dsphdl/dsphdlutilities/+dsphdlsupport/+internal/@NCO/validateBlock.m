function v=validateBlock(~,hC)




    v=hdlvalidatestruct;




    if~isa(hC,'hdlcoder.sysobj_comp')
        if hdlgetparameter('generatevalidationmodel')

            bfp=hC.SimulinkHandle;
            ds=get_param(bfp,'DitherSource');
            if strcmpi(ds,'Property')
                v=hdlvalidatestruct(3,...
                message('dsphdl:NCO:validateBlock:validationmodeldithermismatch'));
            end
        end
    end

end

