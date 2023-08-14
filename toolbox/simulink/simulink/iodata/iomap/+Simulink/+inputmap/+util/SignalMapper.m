classdef SignalMapper<handle





    properties
modelName
signals
signalNames
varNames

aInputSpec
allowPartialSpecs
strongDataTyping
aSimulinkBuildUtility
aCompileStatus

        useWebDiagnostics=false
        webAppInstanceID=''
        forceThrowError=false
    end

    properties(Hidden)
mappedSignalValues
mappedSignalNames
varsToPutInWS

    end


    properties(Hidden=true,GetAccess=protected,SetAccess=protected)
Version
    end

    methods

        function obj=SignalMapper(ModelName,Signals,...
            isPartialSpecAllowed,strongDataTyping,aInputSpec,CompileStatus)
            obj.modelName=ModelName;
            obj.signals=Signals.Data;
            obj.signalNames=[];
            obj.aCompileStatus=CompileStatus;
            obj.strongDataTyping=strongDataTyping;
            obj.allowPartialSpecs=isPartialSpecAllowed;
            obj.aInputSpec=aInputSpec;
            obj.aSimulinkBuildUtility=Simulink.inputmap.util.SimulinkBuildUtility;




            for kCell=1:length(obj.signals)
                if Simulink.sdi.internal.Util.isStructureWithTime(...
                    obj.signals{kCell})||...
                    Simulink.sdi.internal.Util.isStructureWithoutTime(...
                    obj.signals{kCell})

                    obj.varNames=Signals.Names;
                    for kSig=1:length(obj.signals{kCell}.signals)
                        obj.signalNames{length(obj.signalNames)+1}=...
                        Signals.Names{kCell};
                    end
                elseif isa(obj.signals{kCell},'Simulink.SimulationData.Dataset')

                    obj.varNames=Signals.Names;
                    obj.signalNames=Signals.Names;
                    if isfield(Signals,'DatasetID')
                        obj.aSimulinkBuildUtility.DatasetID=Signals.DatasetID;
                    else

                        obj.aSimulinkBuildUtility.DatasetID=[];
                    end

                elseif Simulink.sdi.internal.Util.isTSArray(obj.signals{kCell})||...
                    Simulink.sdi.internal.Util.isMATLABTimeseries(obj.signals{kCell})||...
                    Simulink.sdi.internal.Util.isSimulinkTimeseries(obj.signals{kCell})||...
                    iofile.Util.isValidFunctionCallInput(obj.signals{kCell})

                    obj.varNames=Signals.Names;

                    obj.signalNames{length(obj.signalNames)+1}=...
                    Signals.Names{kCell};

                elseif iofile.Util.isValidTimeExpression(obj.signals{kCell})
                    obj.varNames=Signals.Names;
                    commaIndexes=strfind(obj.signals{kCell},',');
                    for kSig=1:(length(commaIndexes)+1)
                        obj.signalNames{length(obj.signalNames)+1}=...
                        Signals.Names{1};
                    end
                elseif iofile.Util.isValidSignalDataArray(obj.signals{kCell})
                    obj.varNames=Signals.Names;
                    obj.signalNames=Signals.Names;
                else
                    obj.signalNames=Signals.Names;
                    obj.varNames=Signals.Names;
                    break;
                end
            end


            obj.Version=1.2;
        end

        function[mapping,inportProps,dataProps,...
            equalStats,threwError,errorMsg,diagnosticstruct]=map(obj)
            inportProps=[];
            dataProps=[];
            equalStats=[];
            threwError=false;
            errorMsg='';
            diagnosticstruct=[];
            try

                if length(obj.signals)==1&&...
                    isa(obj.signals{1},'Simulink.SimulationData.Dataset')&&...
                    obj.signals{1}.numElements==0
                    mapping=[];

                    DAStudio.error('sl_sta:mapping:datasetNoEl');

                end

                mapping=obj.aInputSpec.getMap(obj.modelName,...
                obj.signalNames,obj.signals);
            catch ME
                threwError=true;

                if obj.forceThrowError

                    rethrow(ME);

                elseif obj.useWebDiagnostics

                    subChannel='sta/mainui/diagnostic/request';
                    fullChannel=sprintf('/sta%s/%s',obj.webAppInstanceID,subChannel);

                    slwebwidgets.errordlgweb(fullChannel,...
                    'sl_inputmap:inputmap:mappingFailedTitle',...
                    ME.message);
                else
                    errordlg(ME.message,DAStudio.message('sl_inputmap:inputmap:mappingFailedTitle'));
                end

                errorMsg=ME.message;

                mapping=Simulink.iospecification.InputMap.empty;
                return;
            end


            if isempty(mapping)

                return;
            end


            [obj.mappedSignalValues,obj.mappedSignalNames,obj.varsToPutInWS]=...
            conditionVerificationInputs(obj,mapping);


            if obj.useWebDiagnostics
                obj.aSimulinkBuildUtility.useWebDiagnostics=true;
                obj.aSimulinkBuildUtility.webAppInstanceID=obj.webAppInstanceID;
                obj.aSimulinkBuildUtility.forceThrowError=obj.forceThrowError;
            end



            [dataProps,inportProps,equalStats,errorMsg,diagnosticstruct]=...
            obj.aSimulinkBuildUtility.buildComparisonVars(...
            obj.modelName,obj.mappedSignalValues,obj.mappedSignalNames,...
            mapping,...
            obj.aCompileStatus,obj.strongDataTyping,obj.allowPartialSpecs,...
            obj.aInputSpec.InputString,obj.varsToPutInWS);


            if isempty(dataProps)&&isempty(inportProps)&&isempty(equalStats)


                mapping=Simulink.iospecification.InputMap.empty(0,0);

            end


        end

    end


    methods(Access=private)


        function tempDataset=orderDataSetByMapping(~,mapping,ds)
            tempDataset=Simulink.SimulationData.Dataset;
            [M,~]=size(mapping);
            for kEl=1:M
                el=ds.getElement(mapping(kEl).DataSourceName);
                tempDataset=tempDataset.add(el,mapping(kEl).DataSourceName);
            end

        end


        function bool=determineComposite(obj)

            inportName=Simulink.iospecification.InportProperty.getInportNames(obj.modelName,false);
            enableName=Simulink.iospecification.InportProperty.getEnableNames(obj.modelName);
            triggerName=Simulink.iospecification.InportProperty.getTriggerNames(obj.modelName);


            numPorts=length([inportName',enableName,triggerName]);

            N=size(obj.signals{1});

            bool=length(obj.signals)==1&&(isa(obj.signals{1},'Simulink.SimulationData.Dataset')...
            ||((iofile.Util.isValidSignalDataArray(obj.signals{1})&&...
            (N(2)-1)==numPorts)||...
            (iofile.Util.isValidSignalDataArray(obj.signals{1})&&~iofile.Util.isFcnCallTableData(obj.signals{1})))...
            ||Simulink.sdi.internal.Util.isStructureWithTime(...
            obj.signals{1})||...
            Simulink.sdi.internal.Util.isStructureWithoutTime(...
            obj.signals{1})||...
            iofile.Util.isValidTimeExpression(obj.signals{1}));

        end

    end


    methods(Hidden)


        function[resultSignals,resultSigNames,varsToPutInWS]=...
            conditionVerificationInputs(obj,mapping)

            resultSigNames{length(mapping)}=[];


            if obj.determineComposite()
                resultSignals{1}=obj.signals{1};
            else
                resultSignals{length(mapping)}=[];

            end

            varNamesForWS=cell(1,length(mapping));
            for kResult=1:length(mapping)
                resultSigNames{kResult}=mapping(kResult).DataSourceName;

                if~obj.determineComposite()
                    if~isempty(mapping(kResult).DataSourceName)
                        resultSignals{kResult}=obj.signals{strcmp(mapping(kResult).VariableName,obj.signalNames)};%#ok<AGROW>
                        varNamesForWS{kResult}=mapping(kResult).VariableName;
                    else
                        resultSignals{kResult}=[];%#ok<AGROW>
                    end
                end
            end


            if~obj.determineComposite()


                varsToPutInWS=varNamesForWS;
                varsToPutInWS(cellfun(@isempty,varsToPutInWS))=[];
            else



                varsToPutInWS=obj.varNames;
            end


        end
    end


end
