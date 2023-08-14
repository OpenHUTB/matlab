function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    [~,any_double,~]=checkForDoublePorts(this,[hC.PirInputPorts(1),hC.PirOutputPorts(1)]);
    if any_double
        v(end+1)=hdlvalidatestruct(1,...
        message('visionhdl:EdgeDetector:DoubleType'));
    end

    if isa(hC,'hdlcoder.sysobj_comp')
        inType=hC.PirInputSignals(1).Type;
        dI=struct(inType);
        if isfield(dI,'Dimensions')
            v(end+2)=hdlvalidatestruct(1,...
            message('visionhdl:EdgeDetector:MultiPixelSystemObjectHDL'));

        end
    end