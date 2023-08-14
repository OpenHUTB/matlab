classdef(Abstract)SlbiCommon<optim.algorithm.GeneralizedLinear













    properties(Hidden,SetAccess=protected,GetAccess=public)
        SlbiCommonVersion=1;
    end


    methods

        function obj=SlbiCommon()
        end

    end


    methods(Hidden,Access=public)

        function[exitflag,exitmsg]=createExitflagAndMsg(obj,slbiexitcode)








            if isempty(regexp(slbiexitcode,'_NaN_','once'))
                [exitflag,exitmsg]=createExitflagAndMsgNormalTermination(...
                obj,slbiexitcode);
            else
                [exitflag,exitmsg]=createExitflagAndMsgUnknownTermination(...
                obj,slbiexitcode);
            end

        end

    end


    methods(Hidden,Access=private)

        function[exitflag,exitmsg]=createExitflagAndMsgNormalTermination(obj,slbiexitcode)



            [exitflag,exitMessageLabel,holeInfo]=getExitInfo(obj,slbiexitcode);


            messageID=sprintf([obj.ExitMessageCatalog,':%s'],...
            exitMessageLabel);



            exitmsg=getString(message(messageID,holeInfo{:}));

        end

        function[exitflag,exitmsg]=createExitflagAndMsgUnknownTermination(~,slbiexitcode)

            idxExitCodeStart=regexp(slbiexitcode,'_NaN_','end')+1;
            exitflag={NaN,slbiexitcode(idxExitCodeStart:end)};
            exitmsg='';

        end

    end

end
