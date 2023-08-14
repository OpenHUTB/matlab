
function[IOBlocksList,portsConnectingToSubsystem,prtList]=getSubsystemConnections(subSys)


    mdlName=Simulink.SimplifyModel.getSubsystemName(subSys);
    load_system(mdlName);

    referredModel='';
    if strcmp(get_param(subSys,'BlockType'),'ModelReference')
        referredModel=get_param(subSys,'ModelName');
        if~bdIsLoaded(referredModel)
            load_system(referredModel);
        end
    end














    IOBlocksList=[];
    portsConnectingToSubsystem=[];
    prtList=[];

    portHandles=get_param(subSys,'PortHandles');
    blockTypeList={'Inport','Outport','EnablePort','TriggerPort','StatePort','PMIOPort','PMIOPort','ActionPort'};

    portTypes=fields(portHandles);
    for k=1:length(portTypes)
        portHandle=portHandles.(portTypes{k});
        if~isempty(referredModel)
            blocksList=find_system(referredModel,'SearchDepth',1,'LookUnderMasks','all','BlockType',blockTypeList{k});
        else
            blocksList=find_system(subSys,'SearchDepth',1,'LookUnderMasks','all','BlockType',blockTypeList{k});
        end




        for i=1:length(portHandle)
            temp1=Simulink.SimplifyModel.getPortConnections(portHandle(i),true);
            temp2={};
            temp3=[];
            for j=1:length(blocksList)
                if strcmpi(portTypes{k},'Enable')||strcmpi(portTypes{k},'Trigger')||strcmpi(portTypes{k},'Ifaction')||strcmpi(portTypes{k},'State')
                    temp2{end+1}=blocksList{j};%#ok<*AGROW>
                elseif str2double(get_param(blocksList{j},'Port'))==i
                    temp2{end+1}=blocksList{j};
                end
            end
            if~isempty(temp1)&&isempty(temp2)

            end

            for j=1:length(temp2)
                pH=get_param(temp2{j},'PortHandles');
                if strcmpi(get_param(temp2{j},'BlockType'),'Inport')
                    temp3=[temp3,Simulink.SimplifyModel.getPortConnections(pH.Outport)];
                elseif strcmpi(get_param(temp2{j},'BlockType'),'Outport')
                    temp3=[temp3,Simulink.SimplifyModel.getPortConnections(pH.Inport)];
                elseif strcmpi(get_param(temp2{j},'BlockType'),'PMIPort')
                    temp3=[temp3,Simulink.SimplifyModel.getPortConnections(pH.(portTypes{k}))];
                end
            end

            evalc(['portsConnectingToSubsystem.',portTypes{k},'{i} = temp1;']);
            evalc(['IOBlocksList.',portTypes{k},'{i} = temp2;']);
            evalc(['prtList.',portTypes{k},'{i} = temp3;']);
        end

    end

