classdef(Sealed)ResultsToDataTypeTableAdapter<SimulinkFixedPoint.datatypecollector.ResultsToTableAdapter











    methods
        function tableWithTypes=getTable(~,allResults)
            nResults=numel(allResults);
            tableWithTypes=table('Size',[nResults,4],...
            'VariableTypes',{'string','string','cell','string'},...
            'VariableNames',{'SID','DTString','DTContainer','DisplayLabel'},...
            'RowNames',string(1:nResults));


            for iResult=1:nResults
                result=allResults{iResult};
                uid=result.getUniqueIdentifier();
                object=uid.getObject();
                try
                    sid=Simulink.ID.getSID(object);
                    foundSID=sid~="";
                catch err %#ok<NASGU> % Not all objects have SID
                    foundSID=false;
                end
                if foundSID
                    tableWithTypes{iResult,"SID"}=string(sid);
                end
            end


            for iResult=1:nResults
                tableWithTypes{iResult,"DisplayLabel"}=string(allResults{iResult}.getDisplayLabel());
            end


            compiledTypes=cell(nResults,1);
            for iResult=1:nResults
                if tableWithTypes{iResult,"SID"}~=""
                    result=allResults{iResult};
                    uid=result.getUniqueIdentifier();
                    object=uid.getObject();
                    pathitem=uid.getElementName();
                    if strcmp(pathitem,'Output')
                        pathitem='1';
                    end
                    try
                        if isa(object,'Stateflow.Data')
                            compiledTypes{iResult}=object.CompiledType;
                        elseif isa(object,'Simulink.Outport')
                            compiledTypes{iResult}=get(object.PortHandles.Inport,'CompiledPortDataType');
                        else
                            portHandles=object.PortHandles.Outport;
                            portNumber=str2double(pathitem);
                            portHandle=portHandles(portNumber);
                            compiledTypes{iResult}=get(portHandle,'CompiledPortDataType');
                        end
                    catch
                    end
                end
            end


            for iResult=1:nResults
                tableWithTypes{iResult,"DTString"}="";
            end




            for iResult=1:nResults
                if~isempty(compiledTypes{iResult})
                    dtContainer=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(compiledTypes{iResult},[]);
                    if~dtContainer.isUnknown
                        tableWithTypes{iResult,"DTContainer"}={dtContainer};
                        tableWithTypes{iResult,"DTString"}=string(compiledTypes{iResult});
                    end
                end
            end

            for iResult=1:nResults
                if tableWithTypes{iResult,"DTString"}==""
                    result=allResults{iResult};
                    dtContainer=result.getSpecifiedDTContainerInfo();
                    tableWithTypes{iResult,"DTContainer"}={dtContainer};
                    if~dtContainer.isUnknown
                        tableWithTypes{iResult,"DTString"}=string(dtContainer.evaluatedDTString);
                    end
                end
            end
        end
    end
end


