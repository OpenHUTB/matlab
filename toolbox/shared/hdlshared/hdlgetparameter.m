function paramvalue=hdlgetparameter(param)



    if hdlisfiltercoder
        hdl_parameters=PersistentHDLPropSet;
        if isempty(hdl_parameters)
            paramvalue=[];
        else
            paramvalue=hdl_parameters.INI.getProp(param);
        end
    else
        hDriver=hdlcurrentdriver;
        if isempty(hDriver)||~isa(hDriver,'slhdlcoder.HDLCoder')

            paramvalue=[];
        else
            paramvalue=hDriver.getParameter(param);
        end
    end
end


