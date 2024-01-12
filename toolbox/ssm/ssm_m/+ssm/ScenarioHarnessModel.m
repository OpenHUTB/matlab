classdef ScenarioHarnessModel<handle

    properties(Access=private)
        fMF0ModelObj;
        fSystem;
        fDTInfo;
        fRapidTargets=[];
        fStopTime;
        fInModelInstances;
        fIdx=0;
        fisGenerated=false;
    end

    methods(Access=public)
        function obj=ScenarioHarnessModel(modelObj)
            checkMf0ObjectAndAssign(obj,modelObj);
        end

        function delete(obj)
            cleanup(obj);
        end

        function h=generate(obj,modelName)

            if obj.fisGenerated
                error('The top model was already generated');
            end


            for j=1:length(obj.fRapidTargets)
                dir=fileparts(obj.fRapidTargets(j));
                ssm.generateTarget(dir,pwd,obj.fRapidTargets(j));
            end


            obj.fSystem=modelName;
            load_system(new_system(obj.fSystem));
            h=get_param(obj.fSystem,'Handle');
            set_param(obj.fSystem,'StopTime',num2str(obj.fStopTime));



            scenarioBlk=add_block('built-in/Scenario',[obj.fSystem,'/ScenarioBlock']);
            set_param(scenarioBlk,'Position',[15+350,15+135,65+350,65+135]);


            for i=1:length(obj.fDTInfo)
                name=obj.fDTInfo(i).name;

                blk=add_block('built-in/DataTable',[gcs,'/',name]);
                set_param(blk,'Position',[(15+350+i*100),(15+135),(65+350+i*100),(65+135)]);


                cmd="load("+"'"+string(obj.fDTInfo(i).busObjLocation)+"')";
                evalin('base',cmd);

                set_param(blk,'TableName',name,'BusType',obj.fDTInfo(i).dataType);
                set_param(blk,'InitialValue',obj.fDTInfo(i).initValues);
                set_param(blk,'Logging',obj.fDTInfo(i).enableLogging);
            end


            items=obj.fMF0ModelObj.topLevelElements;
            x=40;
            y=250;
            for j=1:length(obj.fInModelInstances)
                inst=obj.fInModelInstances(j);
                agentType=items(obj.fIdx).agentTypes.getByKey(inst.agentType);

                if(agentType.modelType==mf.ssm.AgentModelType.Simulink&&...
                    agentType.simulationMode==mf.ssm.AgentSimulationMode.Interpreted)
                    h=insertModelRef(obj,agentType,inst);


                    if(x>700)
                        x=40;
                        y=y+100;
                    end
                    set_param(h,'Position',[x,y,(65+x),(65+y)]);
                    x=x+100;
                end
            end


            hdl=get_param(obj.fSystem,'handle');
            ssm.setModel(hdl,obj.fMF0ModelObj);


            obj.fisGenerated=true;
        end

        function out=simulate(obj,varargin)

            if isempty(obj.fSystem)
                error('The top model was not generated');
            end

            blockingSim=true;
            if nargin>1
                blockingSim=varargin{1};
            end

            if blockingSim
                out=sim(obj.fSystem);
            else
                out=[];
                set_param(obj.fSystem,'SimulationCommand','start');
            end
        end

        function openSystem(obj)
            if isempty(obj.fSystem)
                error('The top model was not generated. Call the generate() method.');
            end

            open_system(obj.fSystem);
        end

        function setStopTime(obj,stopTime)
            if isempty(obj.fSystem)
                error('The top model was not generated. Call the generate() method.');
            end

            set_param(obj.fSystem,'StopTime',num2str(stopTime));
        end

        function sys=saveSystem(obj,filePath)
            if~exist('filePath','var')
                error('Not enough input arguments. Argument ''filePath'' was not specified.');
            end

            [loc,fname,ext]=fileparts(filePath);

            if regexp(fname,'[/\*:?"<>|]','once')
                error(['The given filename: ',fname,' is not a valid filename.']);
            end

            if~strcmp(ext,'.slx')
                error('The given filename should end with ''.slx'' extension.');
            end

            if~exist(loc,'dir')
                error(['The given folder ''',loc,''' does not exist''.slx'' extension.']);
            end

            obj.fSystem=save_system(obj.fSystem,filePath);
            sys=obj.fSystem;
        end

        function h=getModelHandle(obj)
            if isempty(obj.fSystem)
                error('The top model was not generated. Call generate() method.');
            end
            h=get_param(obj.fSystem,'Handle');
        end

        function cleanup(obj)

            if~isempty(obj.fSystem)
                bdclose(obj.fSystem);


                [loc,~,~]=fileparts(obj.fSystem);
                if~isempty(loc)
                    delete([obj.fSystem]);
                end

                obj.fSystem=[];
                obj.fisGenerated=false;
            end


            for i=1:length(obj.fDTInfo)
                cmd="clear("+"'"+string(obj.fDTInfo(i).dataType)+"')";
                evalin('base',cmd);
            end
        end
    end

    methods(Access=private)
        function checkMf0ObjectAndAssign(obj,modelObj)
            items=modelObj.topLevelElements;
            idx=0;
            for i=1:length(items)
                if strcmp(items(i).MetaClass.name,'ScenarioDescriptor')
                    idx=i;
                    break;
                end
            end

            if idx==0

                error('ScenarioDescriptor object not found in the model');
            end

            obj.fIdx=idx;




            if(~isnumeric(items(idx).simulationSettings.synchronizationPeriod)...
                &&items(idx).simulationSettings.synchronizationPeriod>0)
                error('Synchronization period must be a numeric value greater than 0');
            end

            if(~isnumeric(items(idx).simulationSettings.stopTime)...
                &&items(idx).simulationSettings.stopTime>0)
                error('Simulation stopTime must be a numeric value greater than 0');
            else
                obj.fStopTime=items(idx).simulationSettings.stopTime;
            end




            numAgents=items(idx).agentTypes.Size;
            for i=1:numAgents
                key=items(idx).agentTypes.keys{i};
                val=items(idx).agentTypes.getByKey(key);

                if(~any(exist(val.artifactLocation,'file')==[2,4]))
                    error(['Artifact ''',val.artifactLocation,''' does not exist for agent ',val.name]);
                end



                if val.simulationMode==mf.ssm.AgentSimulationMode.Accelerated
                    obj.fRapidTargets=[obj.fRapidTargets,string(val.artifactLocation)];
                end


                if(~isnumeric(val.defaultLifespan)...
                    &&items(idx).simulationSettings.synchronizationPeriod>0)
                    error(['DefaultLifespan for ''',val.name,''' should be a numeric value greater than 0']);
                end
            end




            i=1;
            while i<=items(idx).agentGenerators.Size
                key=items(idx).agentGenerators.keys{i};
                val=items(idx).agentGenerators.getByKey(key);


                agentDef=items(idx).agentTypes.getByKey(val.agentType);
                if isempty(agentDef)
                    error(['Agent type: ''',val.agentType,''' given in agent generator: ''',key,''' does not exist.']);
                end


                k=1;
                while k<=val.instances.Size
                    inst=val.instances(k);
                    if(~isnumeric(inst.birthTime)&&inst.birthTime>0)
                        error(['Birth time for agent instance ''',val.name,''' should be a numeric value greater than 0']);
                    end



                    if strcmp(inst.coSimulationOption,'InModel')
                        if agentDef.simulationMode~=mf.ssm.AgentSimulationMode.Interpreted
                            error(['Cosimulation option for Agent instance ''',val.name...
                            ,''' is set to ''InModel''. But the agentType is set not in ''Interpreted'' mode.']);
                        end

                        if(inst.birthTime~=0)
                            error(['Birth time for "InModel" agent instance ''',val.name,''' should be 0']);
                        end

                        in_val.name=val.name;
                        in_val.type=val.type;
                        in_val.functionName=val.functionName;
                        in_val.agentType=val.agentType;
                        in_val.instance=inst;

                        obj.fInModelInstances=[obj.fInModelInstances,in_val];
                    end
                    k=k+1;
                end

                i=i+1;
            end




            obj.fMF0ModelObj=modelObj;




            numResources=items(idx).sharedResources.Size;
            for i=1:numResources
                key=items(idx).sharedResources.keys{i};
                val=items(idx).sharedResources.getByKey(key);


                obj.fDTInfo(i).name=val.name;
                obj.fDTInfo(i).dataType=val.dataType;


                if(~any(exist(val.busObjLocation,'file')==[2,4]))
                    error(['Bus object ',val.busObjLocation,' does not exist.']);
                end
                obj.fDTInfo(i).busObjLocation=val.busObjLocation;

                obj.fDTInfo(i).initValues='';
                for k=1:val.initialValues.Size
                    name=val.initialValues(k).name;
                    value=val.initialValues(k).value;
                    obj.fDTInfo(i).initValues=[obj.fDTInfo(i).initValues...
                    ,name,'|',value,'|'];
                end

                if val.enableLogging
                    obj.fDTInfo(i).enableLogging='on';
                else
                    obj.fDTInfo(i).enableLogging='off';
                end
            end

        end

        function modelBlkHdl=insertModelRef(obj,agentType,instance)
            mdlBlkPath='simulink/Ports & Subsystems/Model';


            mdlBlkName=[agentType.name,'_',instance.name];


            modelBlkHdl=add_block(mdlBlkPath,[obj.fSystem,'/',mdlBlkName]);
            [path,name,ext]=fileparts(agentType.artifactLocation);

            try
                set_param(modelBlkHdl,'ModelName',name);
            catch eCause
                error(['Error adding model reference block for InModel agent instance "'...
                ,instance.name,'" with agent location ',path,filesep,name,ext...
                ,'. Caused by: ',eCause.message]);
            end


            try
                args=struct();
                for i=1:instance.instance.parameters.Size
                    key=instance.instance.parameters.keys{i};
                    val=instance.instance.parameters.getByKey(key);

                    args.(key)=val.value;
                end
                set_param(modelBlkHdl,'ParameterArgumentValues',args);
            catch eCause
                error(['Error adding model reference block for InModel agent instance "'...
                ,instance.name,'" with agent location ',path,filesep,name,ext...
                ,'. Caused by: ',eCause.message]);
            end
        end
    end
end
