function smartbuildon=isSmartbuildOn(isMLHDLC,varargin)





    if(isMLHDLC)
        smartbuildon=0;
    else
        if(numel(varargin)~=1)
            error('please provide the model name for simulink flow');
        else
            modelname=varargin{1};
            smartbuildon=strcmp(hdlget_param(modelname,'HDLWFSmartbuild'),'on');
        end
    end

end


