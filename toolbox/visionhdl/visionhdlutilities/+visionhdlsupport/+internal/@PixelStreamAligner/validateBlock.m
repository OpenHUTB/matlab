function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    [~,any_double,~]=checkForDoublePorts(this,[hC.PirInputPorts(1),hC.PirInputPorts(3),...
    hC.PirOutputPorts(1),hC.PirOutputPorts(2)]);
    if any_double
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:PixelStreamAligner:DoubleType'));
    end


    if isa(hC,'hdlcoder.sysobj_comp')
        inType=hC.PirInputSignals(1).Type;
        dI=struct(inType);
        if isfield(dI,'Dimensions')
            if length(dI.Dimensions)>1
                v(end+2)=hdlvalidatestruct(1,...
                message('visionhdl:PixelStreamAligner:MulPixMulCompSystemObjectHDL'));
            end
        end
    end
end
