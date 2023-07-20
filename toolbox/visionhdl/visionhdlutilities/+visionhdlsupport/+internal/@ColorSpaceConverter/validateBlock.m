function v=validateBlock(~,hC)




    v=hdlvalidatestruct;



    if isa(hC,'hdlcoder.sysobj_comp')
        inType=hC.PirInputSignals(1).Type;
        dI=struct(inType);
        if isfield(dI,'Dimensions')
            if length(dI.Dimensions)>1
                v(end+2)=hdlvalidatestruct(1,...
                message('visionhdl:ColorSpaceConverter:MatrixSystemObjectHDL'));
            end
        end
    end

