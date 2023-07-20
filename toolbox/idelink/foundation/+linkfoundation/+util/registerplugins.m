function[isok,msg]=registerplugins(flag,dllFileName,ocxFileName,processFileName,processName,keyName)





    hresult=ideregisterplugins(...
    flag,...
    dllFileName,...
    ocxFileName,...
    processFileName,...
    processName,...
keyName...
    );

    switch(computer('arch'))
    case 'win64',
        if(hresult(1))
            hresult(2)=callregister64(flag,ocxFileName);
        end
    end

    isok=hresult(1)&&hresult(2);
    msg=getReport(flag,isok);




    function isok=callregister64(flag,ocxFileName)
        if flag
            regsvrcmd='regsvr32 /s';
        else
            regsvrcmd='regsvr32 /s /u';
        end
        [state,~]=system([regsvrcmd,' "',ocxFileName,'"']);
        isok=(state==0);




        function report=getReport(flag,isok)
            if flag
                if isok
                    reason=message('ERRORHANDLER:utils:PluginRegistrationSuccessful');
                else
                    reason=message('ERRORHANDLER:utils:PluginRegistrationUnsuccessful');
                end
            else
                if isok
                    reason=message('ERRORHANDLER:utils:PluginUnregistrationSuccessful');
                else
                    reason=message('ERRORHANDLER:utils:PluginUnregistrationUnsuccessful');
                end
            end
            report=[linkfoundation.util.getProductName,': ',reason.getString];
