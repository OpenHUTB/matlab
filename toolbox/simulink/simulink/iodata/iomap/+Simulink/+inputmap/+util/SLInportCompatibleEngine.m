classdef SLInportCompatibleEngine<handle




    properties
AllowPartial
    end


    methods


        function[status,diagnosticstruct]=isExternalInputCompatible(obj,model,SignalsStruct,mappingStruct)


            externalInputPlugin=getExternalInputInterface(obj,SignalsStruct,mappingStruct);

            [status,diagnosticstruct]=determineCompatibility(obj,model,externalInputPlugin,mappingStruct);
        end



        function externalInputPlugin=getExternalInputInterface(obj,SignalsStruct,mappingStruct)
            NUM_SIG=length(SignalsStruct.Signals);


            if NUM_SIG==1


                if isa(SignalsStruct.Signals{1},'Simulink.SimulationData.Dataset')

                    externalInputPlugin=Simulink.iospecification.ScenarioDataset(SignalsStruct.varNames{1},SignalsStruct.Signals{1});
                elseif Simulink.sdi.internal.Util.isStructureWithTime(SignalsStruct.Signals{1})||...
                    Simulink.sdi.internal.Util.isStructureWithoutTime(SignalsStruct.Signals{1})


                    externalInputPlugin=Simulink.iospecification.StructWAndWithoutTime(SignalsStruct.varNames{1},SignalsStruct.Signals{1});

                elseif iofile.Util.isValidSignalDataArray(SignalsStruct.Signals{1})


                    if~any(cellfun(@isempty,SignalsStruct.SignalNames)&cellfun(@isempty,SignalsStruct.SignalNames))
                        externalInputPlugin=Simulink.iospecification.DataArrayExternalInput(SignalsStruct.varNames{1},SignalsStruct.Signals{1});
                    else

                        if length(mappingStruct.mapping)~=length(SignalsStruct.Signals)
                            for kSigName=1:length(SignalsStruct.SignalNames)
                                if isempty(SignalsStruct.SignalNames{kSigName})
                                    SignalsStruct.Signals{kSigName}=[];
                                end
                            end
                        end
                        externalInputPlugin=Simulink.iospecification.ExternalInput(SignalsStruct.SignalNames,SignalsStruct.Signals);
                    end
                elseif isTimeExpression(SignalsStruct.Signals{1})
                    externalInputPlugin=Simulink.iospecification.TimeExpressionInput(SignalsStruct.SignalNames{1},SignalsStruct.Signals{1});
                else

                    externalInputPlugin=Simulink.iospecification.ExternalInput(SignalsStruct.SignalNames,SignalsStruct.Signals);
                end
            else

                externalInputPlugin=Simulink.iospecification.ExternalInput(SignalsStruct.SignalNames,SignalsStruct.Signals);

            end

        end


        function[status,diagnosticstruct]=determineCompatibility(obj,model,externalInputPlugin,mappingStruct)
            fastRestartIsOn=strcmp(get_param(model,'SimulationStatus'),'compiled');


            nMap=length(mappingStruct.mapping);

            status=zeros(1,nMap);
            diagnosticstruct.datatype=struct('status',0,'diagnosticstext','');
            diagnosticstruct.dimension=struct('status',0,'diagnosticstext','');
            diagnosticstruct.signaltype=struct('status',0,'diagnosticstext','');
            diagnosticstruct.portspecific='';
            diagnosticstruct.status=false;
            diagnosticstruct.modeldiagnostic=[];

            diagnosticstruct(1:nMap)=diagnosticstruct;

            for kInput=1:nMap

                inMapping=mappingStruct.mapping(kInput);

                blockH=find_system(get_param(model,'Handle'),'SearchDepth'...
                ,1,'BlockType',inMapping.Type,'Name',...
                inMapping.Destination.BlockName);




                if ismethod(externalInputPlugin,'getInputVariablePluginFromIndex')
                    inputVariablePlugin=getInputVariablePluginFromIndex(externalInputPlugin,kInput);
                else

                    inputVariablePlugin=getInputVariablePluginFromMapping(externalInputPlugin,inMapping);
                end


                inportFactory=Simulink.iospecification.InportFactory.getInstance();
                inportPlugin=inportFactory.getInportType(blockH);
                inportPlugin.USE_COMPILED_PARAMS=fastRestartIsOn;
                inportPlugin.ALLOW_PARTIAL=obj.AllowPartial;


                diagnosticstruct(kInput)=inportPlugin.areCompatible(inputVariablePlugin);



                status(kInput)=double(diagnosticstruct(kInput).status);

            end

            if~any(status>1)
                status=logical(status);
            end
        end
    end

end
