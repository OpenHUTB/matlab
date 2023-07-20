function[ret,msg]=modelSelectorPreApplyCallback(obj,~)





    ret=true;
    msg='';
    if~isempty(obj.modelName)
        err=[];


        try
            open_system(obj.modelName);
        catch err
            ret=false;
            msg=DAStudio.message('Simulink:taskEditor:ModelCannotBeLoaded',obj.modelName);
            msg=sprintf('%s %s',msg,err.message);
        end


        if isempty(err)&&~isempty(obj.launchCallback)
            feval(obj.launchCallback,obj.modelName);
        end

    else

        ret=false;
        msg=DAStudio.message('Simulink:taskEditor:NoModelSelected');
    end

