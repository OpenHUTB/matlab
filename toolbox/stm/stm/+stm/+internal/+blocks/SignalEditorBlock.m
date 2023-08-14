classdef SignalEditorBlock<stm.internal.blocks.SignalSourceBlock




    properties
data
        fileName='';
        scenarioNames;
        origActiveScenario;
        overrideScenario;
    end
    methods
        function obj=SignalEditorBlock(modelname,overrideScenario)
            if nargin<=1
                overrideScenario='';
            end

            handle=find_system(modelname,...
            'SearchDepth',1,...
            'LoadFullyIfNeeded','off',...
            'FollowLinks','off',...
            'LookUnderMasks','all',...
            'BlockType','SubSystem',...
            'PreSaveFcn','Simulink.signaleditorblock.cb_PreSaveFcn(gcb);');
            if~isempty(handle)
                if~isscalar(handle)
                    MException(message('stm:general:NoSigBuilderFoundInModel',...
                    get_param(modelname,'Name'))).throw;
                else
                    obj.handle=handle{1};
                end
                obj.fileName=get_param(obj.handle,'FileName');
                obj.origActiveScenario=get_param(obj.handle,'ActiveScenario');
                obj.scenarioNames=obj.getComponentNames();
                if strlength(overrideScenario)==0
                    overrideScenario=obj.origActiveScenario;
                end
                obj.overrideScenario=overrideScenario;
                if exist(obj.fileName,'file')==2
                    obj.data=load(obj.fileName,obj.origActiveScenario);
                end
            end
        end

        function handle=getHandle(obj)
            handle=obj.handle;
        end

        function scenarioNames=getComponentNames(obj)
            if strlength(obj.fileName)>0&&exist(obj.fileName,'file')==2
                scenarioNames=Simulink.SimulationData.DatasetRef.getDatasetVariableNames(obj.fileName)';
            else
                scenarioNames={};
            end
            scenarioNames=sort(scenarioNames);
        end

        function runId=getSignalFromComponent(obj,scenarioName,fileName)
            dataset=obj.data.(scenarioName);
            runId=obj.getSignalFromDataset(dataset,fileName);
        end

        function[handle,ind]=setActiveComponent(obj,scenario)
            currentName=get_param(obj.handle,'ActiveScenario');
            ind=find(strcmp(currentName,obj.scenarioNames),1);
            obj.validateScenario(scenario);
            set_param(obj.handle,'ActiveScenario',scenario);
            handle=obj.handle;
        end

        function fileName=getFileName(obj)
            fileName=get_param(obj.handle,'Filename');
        end

        function setFileName(obj,fileName)
            set_param(obj.handle,'Filename',fileName);
        end

        function tMax=getMaxTime(obj,groupName)
            dataset=obj.data.(groupName);
            wParser=Simulink.sdi.Instance.engine.WksParser;
            tMax=[];
            parsedData=wParser.parseVariables(struct('VarName','sig','VarValue',dataset));
            for sigId=1:dataset.numElements
                nestedParser=getNestedParser(parsedData{1}.getChildren{sigId});
                time=nestedParser.getTimeValues;
                currTMax=max(time);
                if isempty(tMax)
                    tMax=currTMax;
                else
                    tMax=max(tMax,currTMax);
                end
            end
        end

        function setData(obj,scenarioName)
            obj.overrideScenario=scenarioName;
            if~isempty(scenarioName)
                obj.data=load(obj.fileName,scenarioName);
            end
        end

        function delete(obj,~)



            set_param(obj.handle,'ActiveScenario',obj.origActiveScenario);
        end

        function type=getSignalBlockType(~)
            type='externalInputScenario';
        end

        function validateScenario(obj,scenario)
            if strlength(scenario)==0
                return;
            end

            m=matfile(obj.fileName);
            if~isprop(m,scenario)
                error(message('stm:InputsView:SignalEditorScenarioNotFound',...
                scenario,get_param(obj.handle,'Parent')));
            end
        end
    end

    methods(Static)
        function runId=getSignalFromDataset(dataset,fileName)
            runId=[];
            if strlength(fileName)==0
                runId=Simulink.sdi.createRun('RunName','vars',dataset);
                Simulink.sdi.internal.moveRunToApp(runId,'stm');
            else
                dataSets=dataset;
                save(fileName,'dataSets');
            end
        end
    end
end



function nestedParser=getNestedParser(parser)
    if(isempty(parser.getChildren()))
        nestedParser=parser;
    else
        nestedParser=getNestedParser(parser.getChildren{1});
    end
end
