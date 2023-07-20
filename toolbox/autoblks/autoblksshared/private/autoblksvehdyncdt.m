function[varargout]=autoblksvehdyncdt(varargin)



    block=varargin{1};
    callID=varargin{2};







    if callID==0

        ParamList={'xdot_o',[1,1],{};...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{};...
        'b',[1,1],{};...
        'c',[1,1],{};...
        'g',[1,1],{'gt',0};...
        };

        BlockOptions=...
        {'autolibsharedcommon/Vehicle Body Total Road Load','Vehicle Body Total Road Load';
        'autolibsharedcommon/Vehicle Body Total Road Load Power Input','Vehicle Body Total Road Load Power Input';
        'autolibsharedcommon/Vehicle Body Total Road Load Kinematic Input','Vehicle Body Total Road Load Kinematic Input'};


        input_type=get_param(block,'input_type');


        switch input_type
        case 'Force'
            blkID=1;
        case 'Power'
            blkID=2;
        case 'Kinematic'
            blkID=3;
        end
        autoblksreplaceblock(block,BlockOptions,blkID);
        autoblkscheckparams(block,'Vehicle Body Total Road Load',ParamList);
        varargout{1}={};
    end


    if callID<4
        varargout{1}={};
    end

    if callID==4
        varargout{1}=DrawCommands(block);
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Total Force','Force';'Total Power','Power'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='vehicle_dynamics_total_road_load.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,100,'white');
end