classdef SlInportEngineImpl<Simulink.inputmap.util.SLInportCompatibleEngine




    properties
        COMPILE_COUNT=0
cacheStr
cacheLoadExt
cacheDirty

FORCE_MODEL_TERMINATION
    end


    methods

        function obj=SlInportEngineImpl()
            obj.AllowPartial=true;
        end



        function[status,diagnosticstruct]=isExternalInputCompatible(obj,model,SignalsStruct,mappingStruct)


            nMap=length(mappingStruct.mapping);

            diagnosticstruct.datatype=struct('status',0,'diagnosticstext','');
            diagnosticstruct.dimension=struct('status',0,'diagnosticstext','');
            diagnosticstruct.signaltype=struct('status',0,'diagnosticstext','');
            diagnosticstruct.portspecific='';
            diagnosticstruct.status=false;
            diagnosticstruct.modeldiagnostic=[];

            diagnosticstruct(1:nMap)=diagnosticstruct;

            fastRestartIsOn=strcmp(get_param(model,'SimulationStatus'),'compiled');

            Signals=SignalsStruct.Signals;
            varNames=SignalsStruct.varNames;
            SignalNames=SignalsStruct.SignalNames;
            if~fastRestartIsOn


                cacheModelParameters(obj,model);

                try

                    configObjectToSet=getActiveConfigset(obj,model);
                catch ME_CONFIGSETREF
                    diagnosticstruct.modeldiagnostic=ME_CONFIGSETREF.message;
                    status=[];
                    return;
                end


                setExternalInputParameters(obj,configObjectToSet,'on',mappingStruct.inputStr);



                [dupeVarNames,dupeValues]=cacheBaseWorkspaceDuplicateVars(obj,varNames);

                if length(varNames)~=length(Signals)


                    isVarValEmpty=cellfun(@isempty,SignalNames);


                    placeInBaseWorkspace(obj,varNames,Signals(~isVarValEmpty));

                else

                    placeInBaseWorkspace(obj,varNames,Signals);

                end

                [consStructResults,status,errorMsg]=runEngineCompatibilityCheck(obj,model,configObjectToSet,mappingStruct,varNames,dupeVarNames,dupeValues);

                if~isempty(errorMsg)

                    diagnosticstruct(1).modeldiagnostic=errorMsg;
                end

                nStatus=length(status);
                for k=1:nStatus
                    diagnosticstruct(k).status=status(k);


                    if~strcmpi(consStructResults.Status,'External Input Error')

                        if~diagnosticstruct(k).status
                            diagnosticstruct(k).portspecific=consStructResults.Diagnostics{k,2}.Message;
                        end
                    end
                end

            end

        end


    end


    methods(Hidden)


        function cacheModelParameters(obj,model)
            obj.cacheStr=get_param(model,'ExternalInput');
            obj.cacheLoadExt=get_param(model,'LoadExternalInput');
            obj.cacheDirty=get_param(model,'Dirty');
        end


        function setModelParametersToCache(obj,configObjectToSet)

            set_param(configObjectToSet,'ExternalInput',obj.cacheStr);
            set_param(configObjectToSet,'LoadExternalInput',obj.cacheLoadExt);
            if~isa(configObjectToSet,'Simulink.ConfigSet')
                set_param(configObjectToSet,'Dirty',obj.cacheDirty);
            end
        end


        function configObjectToSet=getActiveConfigset(~,model)


            theCS=getActiveConfigSet(model);

            configObjectToSet=model;
            if isa(theCS,'Simulink.ConfigSetRef')
                configObjectToSet=getRefConfigSet(theCS);
            end
        end


        function setExternalInputParameters(~,configObjectToSet,loadExternalInputVal,inputStr)



            set_param(configObjectToSet,'LoadExternalInput',loadExternalInputVal);
            set_param(configObjectToSet,'ExternalInput',inputStr);
        end


        function[dupeVarNames,dupeValues]=cacheBaseWorkspaceDuplicateVars(obj,varNames)




            list=evalin('base','whos');
            varNamesInWS={list.name};
            dupeVarNames=[];
            dupeValues=[];


            if~isempty(varNamesInWS)


                [dupeVarNames,~,~]=...
                intersect(varNamesInWS,varNames);


                for k=length(dupeVarNames):-1:1
                    dupeValues{k}=evalin('base',dupeVarNames{k});
                end

            end
        end



        function placeInBaseWorkspace(~,varName,varVal)





            for kSig=1:length(varVal)

                assignin('base',varName{kSig},varVal{kSig});
            end

        end


        function[consStructResults,equalStatsOverride,errorMsg]=runEngineCompatibilityCheck(obj,model,configObjectToSet,mappingStruct,varNames,dupeVarNames,dupeValues)

            inputStr=mappingStruct.inputStr;
            mapping=mappingStruct.mapping;
            errorMsg='';
            nMap=length(mapping);
            try
                UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');


                consStructResults=eval([model,'(''compileForExtInputMappingCheck'')']);
                warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage');
                obj.COMPILE_COUNT=obj.COMPILE_COUNT+1;



                consStructResults=decorateResults(obj,model,consStructResults,inputStr);

                equalStatsOverride=false(1,nMap);

                switch lower(consStructResults.Status)


                case 'no errors'

                    equalStatsOverride=ones(1,nMap);


                case 'external input error'






                    [nRow,nCol]=size(consStructResults.Diagnostics);

                    for kDiagnostic=nRow:-1:1
                        if isstruct(consStructResults.Diagnostics{kDiagnostic,nCol})
                            errorStruct=consStructResults.Diagnostics{kDiagnostic,nCol};



                            if(length(errorStruct)>1)
                                errorStruct=errorStruct(1);
                            end

                            break;
                        end

                    end




                    MEfromStruct=MSLException(errorStruct.Handle,errorStruct.MessageID,errorStruct.Message);




                    exceptionsThrown{1}=MEfromStruct;

                    srcRoot=model;
                    nagAboutUpdateDiagram(obj,exceptionsThrown,srcRoot);

                    inportProps=[];
                    dataProps=[];
                    equalStats=zeros(1,nMap);
                    equalStatsOverride=zeros(1,nMap);
                    errorMsg=errorStruct.Message;


                case 'root inport mapping error'

                    [MDiag,NDiag]=size(consStructResults.Diagnostics);



                    if NDiag~=1

                        equalStatsOverride=false(1,MDiag);

                        for kDiag=1:MDiag




                            if strcmpi(consStructResults.Diagnostics{kDiag,2},'no errors')||...
                                (isa(consStructResults.Diagnostics{kDiag,2},'struct')&&isfield(consStructResults.Diagnostics{kDiag,2},'MessageID')&&...
                                strcmp(consStructResults.Diagnostics{kDiag,2}.MessageID,'Simulink:SimInput:LoadingCannotInterpFiOrEnum'))







                                equalStatsOverride(kDiag)=1;

                            end

                        end



                        if Simulink.iospecification.InportProperty.hasBusElementPortsAtRoot(model)

                            [portH,portBlkPath,portName,portSigName,portNum]=...
                            Simulink.iospecification.InportProperty.getInportProperties(model);
                            portNum=cell2mat(portNum);
                            [portNumFiltered,~,~]=unique(portNum);

                            tmpDiagnostics=cell(length(portNumFiltered),2);


                            inportStatuses=false(1,length(portNumFiltered));

                            for k=1:length(portNumFiltered)

                                portNumIndexes=find(portNum==portNumFiltered(k));

                                if length(portNumIndexes)==1
                                    inportStatuses(k)=equalStatsOverride(portNumIndexes);
                                    tmpDiagnostics(k,:)=consStructResults.Diagnostics(portNumIndexes,:);
                                else
                                    inportStatuses(k)=all(equalStatsOverride(portNumIndexes));

                                    if any(equalStatsOverride(portNumIndexes)==0)

                                        portIndicesIntoDiagnostic=portNumIndexes(equalStatsOverride(portNumIndexes)==0);
                                        tmpDiagnostics(k,:)=consStructResults.Diagnostics(portIndicesIntoDiagnostic(1),:);
                                    else


                                        tmpDiagnostics(k,:)=consStructResults.Diagnostics(portNumIndexes(1),:);
                                    end

                                end

                            end
                            consStructResults.Diagnostics=tmpDiagnostics;

                            if length(portNum)>length(equalStatsOverride)
                                equalStatsOverride=[inportStatuses,equalStatsOverride(length(portNum)+1:end)];
                            else
                                equalStatsOverride=inportStatuses;
                            end
                        end
                    end
                end

                cleanUpAfterCompile(obj,model,varNames,dupeVarNames,dupeValues,configObjectToSet,UNITS_WARN_STATE_PREV);


            catch ME
                consStructResults=struct;

                cleanUpAfterCompile(obj,model,varNames,dupeVarNames,dupeValues,configObjectToSet,UNITS_WARN_STATE_PREV);







                if~isempty(ME.handles)
                    exceptionsThrown{1}=ME;
                else
                    exceptionsThrown=ME.cause;
                end

                srcRoot=model;
                nagAboutUpdateDiagram(obj,exceptionsThrown,srcRoot);

                equalStatsOverride=[];
                errorMsg=exceptionsThrown{1}.message;
                return;

            end
        end


        function cleanUpAfterCompile(obj,model,varNames,dupeVarNames,dupeValues,configObjectToSet,UNITS_WARN_STATE_PREV)

            if~strcmpi(get_param(model,'SimulationStatus'),'stopped')&&obj.FORCE_MODEL_TERMINATION
                UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');
                eval([model,'([],[],[],''term'')']);
                warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage');
            end








            for kSig=1:length(varNames)
                evalin('base',['clear ',varNames{kSig}]);
            end



            if~isempty(dupeVarNames)

                placeInBaseWorkspace(obj,dupeVarNames,dupeValues);
            end

            if obj.FORCE_MODEL_TERMINATION
                setModelParametersToCache(obj,configObjectToSet)
            end

            warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage');
        end


        function nagAboutUpdateDiagram(obj,exceptionsThrown,srcRoot)





            component=DAStudio.message('sl_inputmap:inputmap:figureTitle');



            for kME=1:length(exceptionsThrown)




                sldiagviewer.reportError(exceptionsThrown{kME});

            end



        end


        function consStructResults=decorateResults(~,model,consStructResults,inputStr)

        end

    end
end
