classdef(Sealed)MWAccountLogin<handle




    properties(GetAccess=public,SetAccess=private)

        ResultIsValid=true

        IsLoggedIn=true
        UserName=''





        LoginToken=''
    end

    properties(Access=private)
noAuthenticationListener
defaultAuthenticationListener
    end

    methods












        function initiateLoginCheck(obj,workflowDoneFcn)
            if~exist('workflowDoneFcn','var')
                workflowDoneFcn=[];
            end
            initiateLoginWorkflow(obj,workflowDoneFcn,'no_authentication','noAuthenticationListener');
        end




















        function initiateDefaultLoginWorkflow(obj,workflowDoneFcn)
            if~exist('workflowDoneFcn','var')
                workflowDoneFcn=[];
            end
            initiateLoginWorkflow(obj,workflowDoneFcn,'default_authentication','defaultAuthenticationListener');
        end

    end

    methods(Access=private)

        function initiateLoginWorkflow(obj,workflowDoneFcn,validationStrategyStr,listenerStr)

        end

        function parseWorkFlowReturn(obj,eventdata)

        end

    end


    methods(Static)
        function testReset()
            hwconnectinstaller.internal.MWAccountLogin.testForceNewAuthentication(false);
            hwconnectinstaller.internal.MWAccountLogin.testForceLoginResult('none');
        end








        function testForceNewAuthentication(doForce)

        end



















        function testForceLoginResult(wrType)

        end

        function wrType=testGetForceLoginStatus()

        end
    end

    methods(Static,Access=private)



        function displayWorkflowReturn(wr)
            status=char(wr.getCompletionStatus());
            if strcmp(status,'SUCCEEDED')&&~isempty(wr.getLoginResponse())
                loginResponse=wr.getLoginResponse();
                msg=sprintf('MWAccountLogin: Status = %s, mwausername = %s, token = %s\n',...
                status,...
                char(loginResponse.getMwaUserName()),...
                char(loginResponse.getToken()));
            else
                msg=sprintf('MWAccountLogin: Status=%s, failuretype = %s\n',...
                status,char(wr.getFailureType()));
            end
            hwconnectinstaller.internal.inform(msg);
        end
    end

end
