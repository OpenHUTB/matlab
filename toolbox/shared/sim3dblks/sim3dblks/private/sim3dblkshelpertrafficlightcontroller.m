function[varargout]=sim3dblkshelpertrafficlightcontroller(varargin)

    varargout{1}={};

    block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(block);
    case 'InitVehTagList'
        InitVehTagList(block);
    case 'UpdateFieldsMode'
        UpdateMode(block);
    case 'setTimings'
        setTimings(block);
    end
end


function Initialization(block)

    numHelperBlock=find_system(bdroot(block),'helperTrafficLightCheck','0');

    if numel(numHelperBlock)>1
        error(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:multipleHelperBlocks'));
    end

    Simulation3DEngine.getEngineBlocks(block);
    editorMode=find_system(bdroot(block),'ProjectFormat','Unreal Editor');


    sceneSelected=find_system(bdroot(block),'SceneDesc','US city block');


    customScene=get_param(block,'customScene');
    if numel(editorMode)==1

        warning(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:editorMode'));
    elseif numel(sceneSelected)==0&&customScene=='0'


        error(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:noUSCityBlock'));
    end

    mode=get_param(block,'modeType');

    autoblkscheckparams(block,{'Ts',[1,1],{'st',0}});




    if strcmp(mode,'Timer-based')
        set_param([block,'/ModeNum'],'value','0');
        set_param([block,'/VehicleID'],'value','-1');
        set_param([block,'/trafficLightID'],'value','trafficLightID');
        set_param([block,'/GreenTime'],'value','greenTime');
        set_param([block,'/YellowTime'],'value','yellowTime');
        set_param([block,'/RedClearanceTime'],'value','redClearanceTime');

        if strcmp(get_param([block,'/Distance'],'BlockType'),'Inport')
            replace_block([block,'/Distance'],'Inport','Constant','noprompt');
            set_param([block,'/Distance'],'value','-1');
        end
        if strcmp(get_param([block,'/TrafficLight'],'BlockType'),'Inport')
            replace_block([block,'/TrafficLight'],'Inport','Constant','noprompt');
            set_param([block,'/TrafficLight'],'value','-1');
        end

        if strcmp(get_param([block,'/States'],'BlockType'),'Inport')
            replace_block([block,'/States'],'Inport','Constant','noprompt');
            set_param([block,'/States'],'value','-1');
        end

        if strcmp(get_param([block,'/State'],'BlockType'),'Inport')
            replace_block([block,'/State'],'Inport','Constant','noprompt');
            set_param([block,'/State'],'value','-1');
        end

        if strcmp(get_param([block,'/UpcomingTrafficLight'],'BlockType'),'Outport')
            replace_block([block,'/UpcomingTrafficLight'],'Outport','Terminator','noprompt');
        end


        validateTimingsMode(block);

    elseif strcmp(mode,'State-based')

        set_param([block,'/ModeNum'],'value','2');
        set_param([block,'/trafficLightID'],'value','-1');
        set_param([block,'/VehicleID'],'value','-1');
        set_param([block,'/GreenTime'],'value','-1');
        set_param([block,'/YellowTime'],'value','-1');
        set_param([block,'/RedClearanceTime'],'value','-1');

        if strcmp(get_param([block,'/Distance'],'BlockType'),'Inport')
            replace_block([block,'/Distance'],'Inport','Constant','noprompt');
            set_param([block,'/Distance'],'value','-1');
        end

        if strcmp(get_param([block,'/State'],'BlockType'),'Inport')
            replace_block([block,'/State'],'Inport','Constant','noprompt');
            set_param([block,'/State'],'value','-1');
        end

        if strcmp(get_param([block,'/TrafficLight'],'BlockType'),'Constant')
            replace_block([block,'/TrafficLight'],get_param([block,'/TrafficLight'],'BlockType'),'Inport','noprompt');
        end

        if strcmp(get_param([block,'/States'],'BlockType'),'Constant')
            replace_block([block,'/States'],get_param([block,'/States'],'BlockType'),'Inport','noprompt');
        end

        if strcmp(get_param([block,'/UpcomingTrafficLight'],'BlockType'),'Outport')
            replace_block([block,'/UpcomingTrafficLight'],'Outport','Terminator','noprompt');
        end
    else

        set_param([block,'/ModeNum'],'value','1');
        set_param([block,'/trafficLightID'],'value','-1');
        set_param([block,'/GreenTime'],'value','-1');
        set_param([block,'/YellowTime'],'value','-1');
        set_param([block,'/RedClearanceTime'],'value','-1');

        if strcmp(get_param([block,'/Distance'],'BlockType'),'Constant')
            replace_block([block,'/Distance'],get_param([block,'/Distance'],'BlockType'),'Inport','noprompt');
        end

        if strcmp(get_param([block,'/State'],'BlockType'),'Constant')
            replace_block([block,'/State'],get_param([block,'/State'],'BlockType'),'Inport','noprompt');
        end

        if strcmp(get_param([block,'/TrafficLight'],'BlockType'),'Inport')
            replace_block([block,'/TrafficLight'],'Inport','Constant','noprompt');
            set_param([block,'/TrafficLight'],'value','-1');
        end

        if strcmp(get_param([block,'/States'],'BlockType'),'Inport')
            replace_block([block,'/States'],'Inport','Constant','noprompt');
            set_param([block,'/States'],'value','-1');
        end

        if strcmp(get_param([block,'/UpcomingTrafficLight'],'BlockType'),'Terminator')
            replace_block([block,'/UpcomingTrafficLight'],get_param([block,'/UpcomingTrafficLight'],'BlockType'),'Outport','noprompt');
        end


        validateEventMode(block);
    end
end



function InitVehTagList(block)

    UpdateDropdowns(block);


    MaskObj=get_param(block,'MaskObject');
    vehTag=MaskObj.getParameter('vehTag');
    vehTag.TypeOptions=strrep(vehTag.TypeOptions,'Scene Origin','- Select Vehicle -');
end



function UpdateMode(block)

    mode=get_param(block,'modeType');
    paramVisibilities=get_param(block,'MaskVisibilities');
    if strcmp(mode,'Timer-based')
        paramVisibilities{6}='off';
        paramVisibilities{7}='on';
        paramVisibilities{8}='on';
        paramVisibilities{9}='on';
        paramVisibilities{11}='on';
    elseif strcmp(mode,'State-based')
        paramVisibilities{6}='off';
        paramVisibilities{7}='off';
        paramVisibilities{8}='off';
        paramVisibilities{9}='off';
        paramVisibilities{11}='off';
    elseif strcmp(mode,'Event-based')
        paramVisibilities{6}='on';
        paramVisibilities{7}='off';
        paramVisibilities{8}='off';
        paramVisibilities{9}='off';
        paramVisibilities{11}='off';
    end
    set_param(block,'MaskVisibilities',paramVisibilities);
end



function validateTimingsMode(block)
    TrafficLightID=str2num(get_param(block,'trafficLightID'));
    GreenTime=str2num(get_param(block,'greenTime'));
    YellowTime=str2num(get_param(block,'yellowTime'));
    RedClearanceTime=str2num(get_param(block,'redClearanceTime'));

    validateattributes(TrafficLightID,{'numeric'},{'row','>',0,'integer'},'Traffic Light Controller','Traffic Light ID');

    validateattributes(GreenTime,{'numeric'},{'row','>=',0,'<=',300},'Traffic Light Controller','Green time');

    validateattributes(YellowTime,{'numeric'},{'row','>=',0,'<=',300},'Traffic Light Controller','Yellow time');

    validateattributes(RedClearanceTime,{'numeric'},{'row','>=',0,'<=',300},'Traffic Light Controller','Red Clearance time');


    if(length(TrafficLightID)==length(GreenTime))&&(length(TrafficLightID)==length(YellowTime))&&(length(TrafficLightID)==length(RedClearanceTime))
    else
        error(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:invalidTimingsSize'));
    end
end



function validateEventMode(block)

    if numel(get_param(block,'vehTagList'))==16
        error(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:noVehicle'));
    end

    if strcmp(get_param(block,'vehTag'),'- Select Vehicle -')
        error(message('shared_sim3dblks:sim3dblkHelperTrafficLightController:invalidVehicle'));
    end



    vehBlocks=string(find_system(bdroot(gcb),'LookUnderMasks','on','FollowLinks','on','ActorType','SimulinkVehicle'));
    for i=1:numel(vehBlocks)
        if strcmp(get_param(vehBlocks(i),'ActorTag'),get_param(block,'vehTag'))
            set_param([block,'/VehicleID'],'value',num2str(i-1));
            break;
        end
    end
end