function invoke_rtwbuild_custom_hook(modelName,hook,dependencyObject)






    hcustom=sldowprivate('cusattic','AtticData','RTWBuildCustomizations');
    if~isempty(hcustom)&&~isempty(hcustom.(hook))
        if strcmp(get_param(modelName,'RTWVerbose'),'on')
            disp(['### Invoking custom build hook: ',hook]);
        end
        i_callHook(modelName,hcustom.(hook),dependencyObject);
    end




    function i_callHook(modelName,hook,dependencyObject)
        try
            evalfunc(hook,modelName,dependencyObject);
        catch exc



            errMsg=rtwprivate('escapeOriginalMessage',exc);
            errID='RTW:buildProcess:invalidRTWBuildCustomization';

            newExc=MSLException([],message(errID,hook,errMsg));
            newExc=newExc.addCause(exc);
            throw(newExc);
        end


        function evalfunc(commandToEval,modelName,dependencyObject)%#ok<INUSD>


            eval(commandToEval);


