function setInputParametersCallbackFcn(this,functionHandle)




    if isa(functionHandle,'function_handle')
        this.InputParametersCallback=functionHandle;
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','function_handle');
    end
