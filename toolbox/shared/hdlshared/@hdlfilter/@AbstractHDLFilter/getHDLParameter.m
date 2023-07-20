function paramvalue=getHDLParameter(this,param)





    hdl_parameters=this.HDLParameters;

    if isempty(hdl_parameters)
        paramvalue=[];
    else
        paramvalue=hdl_parameters.INI.getProp(param);
    end



