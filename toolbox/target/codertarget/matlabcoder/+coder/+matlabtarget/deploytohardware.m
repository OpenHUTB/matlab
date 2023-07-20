classdef deploytohardware<handle










    methods
        function obj=deploytohardware(varargin)
        end

        function deploy(obj,functionName,varargin)













            narginchk(2,3);



            if~(isa(obj,'targetHardware')||(isa(obj,'coder.EmbeddedCodeConfig')||isa(obj,'coder.CodeConfig')))
                try
                    error(message('codertarget:matlabtarget:InValidHWOBJ',hardwareObject));
                catch me
                    throwAsCaller(me);
                end
            end


            try
                [filepath,functionName]=coder.matlabtarget.internal.validateFunctionName(functionName);
            catch me
                throwAsCaller(me);
            end


            if nargin>2&&(isa(varargin{1},'coder.EmbeddedCodeConfig')||isa(varargin{1},'coder.CodeConfig'))
                if~ismember(varargin{1}.OutputType,{'LIB','EXE','DLL'})
                    try
                        error(message('codertarget:build:UnsupportedMATLABCoderBuild',obj.Name));
                    catch me
                        throwAsCaller(me);
                    end
                end
                cfg=copy(varargin{1});


                if isempty(cfg.Hardware)
                    cfg.Hardware=coder.matlabtarget.Hardware(obj.Name);
                end


                includeList=getIncludeList(obj.customMainObj);
                if~contains(cfg.CustomHeaderCode,includeList)
                    cfg.CustomHeaderCode=strtrim([cfg.CustomHeaderCode,newline,includeList]);
                end

                targetInitFunc=getTargetInitFunc(obj.customMainObj);
                if~contains(cfg.CustomInitializer,targetInitFunc)
                    cfg.CustomInitializer=strtrim([cfg.CustomInitializer,newline,targetInitFunc]);
                end

                targetTerminateFunc=getTargetTerminateFunc(obj.customMainObj);
                if~contains(cfg.CustomTerminator,targetTerminateFunc)
                    cfg.CustomTerminator=strtrim([cfg.CustomTerminator,newline,targetTerminateFunc]);
                end

            else

                cfg=copy(obj.CoderConfig);
            end


            customTerminateObj=coder.matlabtarget.internal.customTerminateGenerator(cfg,functionName,'srcFileDst',fullfile(pwd,'codegen',lower(cfg.OutputType),functionName));
            customTerminateObj.genrateMainTerminate;
            cfg.CustomSource=strtrim([cfg.CustomSource,' ',fullfile('codegen',lower(cfg.OutputType),functionName,customTerminateObj.getFileName)]);

            try

                if(cfg.LaunchReport)
                    codegen('-config ',cfg,fullfile(filepath,[functionName,'.m']),'-launchreport');
                else
                    codegen('-config ',cfg,fullfile(filepath,[functionName,'.m']));
                end
            catch me
                throwAsCaller(me);
            end
        end
    end
end


