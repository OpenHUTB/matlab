function setStatusBarMessage(msgID,model,varargin)





    if~bdIsLoaded(model)
        return;
    end


    msg='';
    if~isempty(msgID)
        msg=DAStudio.message(['Simulink:cache:',msgID],...
        varargin{:});
    end

    set_param(model,'StatusString',msg);
end