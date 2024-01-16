function paramvalue=genmodelgetparameter(~,param)

    hDriver=hdlcurrentdriver;
    if isempty(hDriver)||~isa(hDriver,'slhdlcoder.HDLCoder')

        paramvalue=[];
    else
        paramvalue=hDriver.getParameter(param);
    end

end