classdef(Sealed)RMIHelper<handle

    methods(Access=private)
        function this=RMIHelper()
            rmitm.UpdateNotifier.register(@this.handleEvnt);
        end

        function handleEvnt(~,~,evt)
            testFile=evt.testFile;
            testID=evt.testId;

            [~,~,fileExt]=fileparts(testFile);


            if~ismember(testFile,{sltest.testmanager.getTestFiles().FilePath})
                return;
            end

            if strcmpi(fileExt,".m")
                stm.internal.updateRequirementsForTestName(testFile,testID);
            else
                stm.internal.updateRequirements(testFile,testID);
            end
        end
    end

    methods(Static)
        function getInstance
            mlock;
            persistent localObj
            if isempty(localObj)||~isvalid(localObj)
                localObj=stm.internal.RMIHelper();
            end
        end
    end
end
