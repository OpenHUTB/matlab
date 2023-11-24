classdef Utils

    methods(Static)

        function retObj=getTestFileObj(absoluteFileAddress)
            retObj=[];
            tfs=sltest.testmanager.getTestFiles();
            for itf=1:numel(tfs)
                tf=tfs(itf);
                if strcmp(tf.FilePath,absoluteFileAddress)
                    retObj=tf;
                    break;
                end
            end
        end

        function absoluteAddr=resolveModelName(modelname)
            if isvarname(modelname)
                if bdIsLoaded(modelname)

                    absoluteAddr=get_param(modelname,'FileName');
                else
                    absoluteAddr=sls_resolvename(modelname);
                end
            else
                absoluteAddr='';
            end
        end

        function specObj=resultToSpec(resObj)
            switch class(resObj)
            case 'sltest.testmanager.TestFileResult'
                specObj=resObj.getTestFile();
            case 'sltest.testmanager.TestSuiteResult'
                specObj=resObj.getTestSuite();
            case 'sltest.testmanager.TestCaseResult'
                specObj=resObj.getTestCase();
            otherwise
                specObj=[];
            end
        end

        function uuid=getSpecUUID(specObj)
            switch class(specObj)
            case 'sltest.testmanager.TestFile'
                uuid=specObj.UUID;
            case 'sltest.testmanager.TestSuite'
                uuid=specObj.UUID;
            case 'sltest.testmanager.TestCase'
                uuid=specObj.UUID;
            case 'sltest.testmanager.TestIteration'
                uuid=specObj.getIterationProperties.uuid;
            otherwise
                uuid='';
            end
        end

        function uuid=getResultUUID(obj)
            switch class(obj)
            case 'sltest.testmanager.ResultSet'
                uuid=obj.UUID;
            case 'sltest.testmanager.TestFileResult'
                uuid='';
            case 'sltest.testmanager.TestSuiteResult'
                uuid='';
            case 'sltest.testmanager.TestCaseResult'
                uuid=obj.ResultUUID;
            case 'sltest.testmanager.TestIterationResult'
                uuid='';
            otherwise
                uuid='';
            end
        end

        function fp=getTestFilePath(obj)
            if~strcmp(class(obj),'sltest.testmanager.TestFile')
                obj=obj.TestFile;
            end
            fp=fullfile(obj.FilePath);
        end

        function b=isDirty(obj)
            if~strcmp(class(obj),'sltest.testmanager.TestFile')
                obj=obj.TestFile;
            end
            b=obj.Dirty;
        end

    end
end
