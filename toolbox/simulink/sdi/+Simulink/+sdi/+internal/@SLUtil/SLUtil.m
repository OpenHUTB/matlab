classdef SLUtil





    methods(Static)
        [VarNameList,TimeSaveName,FileList,scopeVarList]=getLogVarNamesFromModel(ModelName,varargin);
        isHarness=isHarnessModel(mdl);
        testUnitBlock=findTestUnitBlock(obj);

        function outputFileName=createSnapshot(sys,fmt)
            outputFileName='';
            if bdIsLoaded(sys)
                snapObj=SLPrint.Snapshot;
                snapObj.Target=sys;
                snapObj.Format=fmt;
                snapObj.FileName=fullfile(tempdir,sys);
                if exist(snapObj.FileName,'file')
                    delete(snapObj.FileName);
                end
                snapObj.snap;
                outputFileName=snapObj.FileName;
            end
        end

    end


    methods(Static,Access='private')
        [VarNameList,TimeSaveName,FileList,scopeVarList]=getLogVarNamesWithoutMetaData(ModelName,varargin);
    end

end


