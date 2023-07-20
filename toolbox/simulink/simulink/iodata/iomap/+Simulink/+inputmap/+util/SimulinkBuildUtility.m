classdef SimulinkBuildUtility<handle







    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version
    end

    properties(Access=public)

        useWebDiagnostics=false
        webAppInstanceID=''
        forceThrowError=false
DatasetID

        FORCE_MODEL_TERMINATION=true;
        COMPILE_COUNT=0;
    end

    properties(Access=private)
        boolThrowErr=false;
        errIDToThrow={};
        fcnCallDataTypeStr=['double ',DAStudio.message('sl_inputmap:inputmap:fcnCallType')];
        varNames;
        supportedCast={'double','single','int8','uint8','int16','uint16','int32','uint32','boolean'};
AllowPartialBus
CompileModel
ModelName
    end

    methods


        function obj=SimulinkBuildUtility()

            obj.Version=1.1;
        end


        function[dataProps,inportProps,equalStats,errorMsg,diagnosticstruct]=buildComparisonVars(...
            obj,ModelName,Signals,SignalNames,mapping,CompileStatus,strongDataTyping,AllowPartStruct,inputStr,varNames)





            nMap=length(mapping);
            inportProps=cell(1,nMap);
            dataProps=cell(1,nMap);
            equalStats=zeros(1,nMap);

            errorMsg='';


            equalStatsOverride=zeros(1,nMap);

            obj.varNames=varNames;

            obj.AllowPartialBus=AllowPartStruct;
            obj.CompileModel=CompileStatus;
            obj.ModelName=ModelName;





            SignalsStruct.Signals=Signals;
            SignalsStruct.SignalNames=SignalNames;
            SignalsStruct.varNames=varNames;



            mappingStruct.mapping=mapping;
            mappingStruct.inputStr=inputStr;
            fastRestartIsOn=strcmp(get_param(ModelName,'SimulationStatus'),'compiled');

            if castDataType(obj,strongDataTyping)
                strongDataTypeEngine=Simulink.inputmap.util.StrongDataTypeEngineImpl();
                strongDataTypeEngine.CompileStatus=CompileStatus;
                strongDataTypeEngine.DatasetID=obj.DatasetID;
                strongDataTypeEngine.FORCE_MODEL_TERMINATION=obj.FORCE_MODEL_TERMINATION;
                [status,diagnosticstruct]=isExternalInputCompatible(strongDataTypeEngine,ModelName,SignalsStruct,mappingStruct);

                errorMsg=diagnosticstruct.modeldiagnostic;

                if isnumeric(errorMsg)&&isempty(errorMsg)
                    errorMsg='';
                end

                equalStats=status;

                obj.COMPILE_COUNT=obj.COMPILE_COUNT+strongDataTypeEngine.COMPILE_COUNT;
                return;
            end



            if~CompileStatus||fastRestartIsOn
                fugasiEngine=Simulink.inputmap.util.FauxEngineImpl();
                fugasiEngine.AllowPartial=obj.AllowPartialBus;

                [status,diagnosticstruct]=isExternalInputCompatible(fugasiEngine,ModelName,SignalsStruct,mappingStruct);

                errorMsg=diagnosticstruct.modeldiagnostic;

                if isnumeric(errorMsg)&&isempty(errorMsg)
                    errorMsg='';
                end

                equalStats=status;
                return;
            else
                slEngine=Simulink.inputmap.util.SlInportEngineImpl();

                slEngine.FORCE_MODEL_TERMINATION=obj.FORCE_MODEL_TERMINATION;
                [status,diagnosticstruct]=isExternalInputCompatible(slEngine,ModelName,SignalsStruct,mappingStruct);

                errorMsg=diagnosticstruct.modeldiagnostic;

                if isnumeric(errorMsg)&&isempty(errorMsg)
                    errorMsg='';
                end

                equalStats=status;
                if~isempty(status)
                    equalStats=logical(equalStats);
                end
                obj.COMPILE_COUNT=obj.COMPILE_COUNT+slEngine.COMPILE_COUNT;

                if isempty(status)&&~isempty(errorMsg)
                    inportProps=[];
                    dataProps=[];
                    equalStats=[];
                end
                return;
            end

        end

    end

    methods(Access=private)


        function bool=castDataType(obj,strongDataTyping)





            bool=false;

            try
                if slfeature('SpreadsheetDataTypeCastTest')==1


                    bool=true;
                    return;
                end

            catch
                bool=false;
                return;
            end

            if isempty(obj.DatasetID)


                return;
            end
            aRepo=starepository.RepositoryUtility();
            fileName=getMetaDataByName(aRepo,obj.DatasetID,'FileName');
            [~,~,ext]=fileparts(fileName);

            if strcmpi(ext,'.mat')
                return;
            elseif any(strcmpi(ext,{'.xlsx','.xls','.csv'}))
                bool=strongDataTyping~=1;
            else
                return;
            end
        end

    end
end
