











classdef FigureData<handle
    properties(Access=private)
NameToValueMap
    end

    properties(Access=private,Transient=true)
EventListeners
    end

    properties
        DataSourceLabels(1,1)=struct
    end

    properties(Dependent)
NumSims
DataSourceNames
    end

    properties(Constant,Access=private)
        SimStatusColorMap=getSimStatusToColorMap();
    end

    properties(Constant)
        SimStatusParameter=struct('Id','Simulation Status','PostProcess',@(x)x(end))
    end

    events
FigureDataUpdated
SimStatusUpdated
DataSourcesUpdated
DataSourcesFinalized
    end

    methods
        function obj=FigureData()
            obj.NameToValueMap=containers.Map;
        end

        function setFigureData(obj,figureData)
            obj.createNameToValueMap(figureData);
        end

        function connectToJob(obj,multiSimJob)
            delete(obj.EventListeners);
            obj.EventListeners=addlistener(multiSimJob.JobStatusDB,'RunStatusUpdated',...
            @(~,eventData)obj.handleRunStatusChanged(eventData));
            obj.EventListeners(2)=addlistener(multiSimJob.OutputConnection,"SimulationOutputFormatted",...
            @(x,y)obj.updateData(x,y));
            obj.EventListeners(3)=addlistener(multiSimJob.SimulationManager,'SimulationAborted',...
            @obj.simAbortHandler);

            if multiSimJob.SimulationManager.ForRunAll
                numSims=multiSimJob.NumSims;
                evtData=simmanager.designview.EventData(1:numSims);
                notify(obj,'SimStatusUpdated',evtData);
            end
        end

        function numSims=get.NumSims(obj)
            numSims=numel(obj.NameToValueMap('RunId'));
        end

        function sourceNames=get.DataSourceNames(obj)
            sourceNames=keys(obj.NameToValueMap);
        end




        function paramVals=getParamVals(obj,paramStruct)
            if~isKey(obj.NameToValueMap,paramStruct.Id)
                paramVals=nan(obj.NumSims,1);
            else
                paramVals=obj.NameToValueMap(paramStruct.Id);
            end
        end




        function paramVal=getSingleParamVal(obj,paramStruct,runId)
            if~isKey(obj.NameToValueMap,paramStruct.Id)
                paramVal=nan;
            else
                paramVals=obj.NameToValueMap(paramStruct.Id);
                paramVal=paramVals(runId,:);
            end
        end

        function delete(obj)
            delete(obj.EventListeners);
        end
    end

    methods(Access=private)



        function createNameToValueMap(obj,figureData)
            paramNames=fieldnames(rmfield(figureData(1),'Status'));
            if~isempty(paramNames)
                obj.NameToValueMap=containers.Map(paramNames,cellfun(@(x)str2double({figureData.(x)}'),...
                paramNames,'UniformOutput',false),'UniformValues',false);
                cellfun(@(x)obj.removeIfNan(x),obj.NameToValueMap.keys);
            else
                obj.NameToValueMap=containers.Map;
            end
            paramNames=obj.NameToValueMap.keys';
            obj.NameToValueMap(obj.SimStatusParameter.Id)=obj.statusToRGB({figureData.Status});
            obj.NameToValueMap('RunId')=(1:numel(figureData))';

            notify(obj,'DataSourcesUpdated',obj.getNewParameterEventData(paramNames));

            msg=struct('type',slsim.design.FigureDataSourceType.Default,...
            'names',{{obj.SimStatusParameter.Id,'RunId'}});
            notify(obj,'DataSourcesUpdated',simmanager.designview.EventData(msg));
        end



        function removeIfNan(obj,paramName)
            if all(isnan(obj.NameToValueMap(paramName)))
                remove(obj.NameToValueMap,paramName);
            end
        end




        function statusData=statusToRGB(obj,statusStrings)
            statusData=zeros(numel(statusStrings),3);
            for i=1:numel(statusStrings)
                statusData(i,:)=obj.SimStatusColorMap(statusStrings{i});
            end
        end



        function handleRunStatusChanged(obj,eventData)
            for changeIndex=1:numel(eventData.Data)
                newData=eventData.Data(changeIndex);
                runId=newData.RunId;
                simColor=obj.SimStatusColorMap(newData.Status);
                tempVal=obj.NameToValueMap(obj.SimStatusParameter.Id);
                tempVal(runId,:)=simColor;
                obj.NameToValueMap(obj.SimStatusParameter.Id)=tempVal;
            end

            evtData=simmanager.designview.EventData([eventData.Data.RunId]);
            notify(obj,'SimStatusUpdated',evtData);
        end



        function simAbortHandler(obj,~,eventData)
            runIds=eventData.RunIds;
            if isempty(runIds)
                return;
            end

            abortText=message('Simulink:MultiSim:Aborted').getString();
            simColor=obj.SimStatusColorMap(abortText);
            simStatusValues=obj.NameToValueMap(obj.SimStatusParameter.Id);
            simStatusValues(runIds,:)=repmat(simColor,numel(runIds),1);
            obj.NameToValueMap(obj.SimStatusParameter.Id)=simStatusValues;
            evtData=simmanager.designview.EventData(runIds);
            notify(obj,'SimStatusUpdated',evtData);
        end



        function updateData(obj,~,eventData)
            numRunsToUpdate=numel(eventData.Data);
            assert(numRunsToUpdate>0,'FigureData.updateData: at least one run needs to be updated');

            newParams={};
            for i=1:numRunsToUpdate
                runId=eventData.Data(i).runId;
                data=eventData.Data(i).values;

                validateattributes(data,{'struct'},{});
                for dataIndex=1:numel(data)
                    curData=data(dataIndex);
                    curName=curData.name;

                    if~isKey(obj.NameToValueMap,curName)
                        obj.NameToValueMap(curName)=NaN(obj.NumSims,1);
                        newParams=[newParams,{curName}];
                    end

                    curValues=obj.NameToValueMap(curName);
                    curValues(runId)=curData.data;
                    obj.NameToValueMap(curName)=curValues;
                end
            end






            evtData=simmanager.designview.EventData(runId);
            notify(obj,'FigureDataUpdated',evtData);

            if~isempty(newParams)
                msg=struct('type',slsim.design.FigureDataSourceType.Output,...
                'names',{newParams});
                notify(obj,'DataSourcesUpdated',simmanager.designview.EventData(msg));
            end




            evtData=simmanager.designview.EventData(eventData.Data);
            notify(obj,'DataSourcesFinalized',evtData);
        end
    end

    methods(Hidden)


        function numSims=getNumSims(obj)
            numSims=obj.NumSims;
        end
    end

    methods(Static,Hidden=true)
        function eventData=getNewParameterEventData(paramNames)
            msg=struct('type',slsim.design.FigureDataSourceType.Parameter,...
            'names',{paramNames});
            eventData=simmanager.designview.EventData(msg);
        end
    end
end



function simStatusColorMap=getSimStatusToColorMap()
    simStatuses={message('Simulink:MultiSim:Completed').getString(),...
    message('Simulink:MultiSim:Queued').getString(),...
    message('Simulink:MultiSim:Active').getString(),...
    message('Simulink:MultiSim:CompletedWithWarnings').getString(),...
    message('Simulink:MultiSim:Aborted').getString(),...
    message('Simulink:MultiSim:Errors').getString()};






    simColors={[.3,.8,.3],...
    [.75,.75,.75],...
    [0,0,1],...
    [1,0,0],...
    [1,0,0],...
    [1,0,0]};

    simStatusColorMap=containers.Map(simStatuses,simColors);
end
