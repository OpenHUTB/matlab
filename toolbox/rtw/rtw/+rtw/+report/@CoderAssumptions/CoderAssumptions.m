classdef CoderAssumptions<coder.report.ReportPageBase





    properties

ModelName
ModelHandle
BuildDir
    end



    methods
        function obj=CoderAssumptions(model,buildDir)

            obj=obj@coder.report.ReportPageBase();
            obj.ModelName=model;
            obj.ModelHandle=get_param(model,'Handle');
            obj.BuildDir=buildDir;
        end
    end



    methods(Access=private)
        addLanguageStandard(obj,assumptions);
        addFloatingPointNumbers(obj,assumptions);
        addLanguageConfiguration(obj,assumptions);
        out=getLanguageConfigWordLenghts(obj,assumptions,useHost);
        out=getLanguageConfigOther(obj,assumptions,useHost);
    end


    methods(Access=private,Hidden=true)
        function tfStringOut=logicalToTFString(~,logicalIn)
            if logicalIn
                tfStringOut='True';
            else
                tfStringOut='False';
            end
        end


        function status=needGlobalMemoryZeroInit(obj)



            status=ismember('off',{...
            get_param(obj.ModelName,'ZeroExternalMemoryAtStartup'),...
            get_param(obj.ModelName,'ZeroInternalMemoryAtStartup')});
        end

        function lang=getTargetLang(obj)
            lang=get_param(obj.ModelName,'TargetLang');
        end
    end

    methods(Static,Hidden=true)
        function showMemZeroInitParams(modelName)

            if~bdIsLoaded(modelName)

                load_system(modelName);
            end
            configset.highlightParameter(modelName,...
            {'ZeroExternalMemoryAtStartup','ZeroInternalMemoryAtStartup'});
        end
    end

end


