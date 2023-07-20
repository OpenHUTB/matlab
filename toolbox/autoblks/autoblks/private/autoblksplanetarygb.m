function[varargout]=autoblksplanetarygb(varargin)



    block=varargin{1};
    maskMode=varargin{2};


    BlockNames={'Reduced Planetary Gear Tin';'Reduced Planetary Gear win';...
    'Reduced Planetary Gear Tin 2way';'Reduced Planetary Gear win 2way'};

    if maskMode==0

        port_config=get_param(block,'port_config');
        input_config=get_param(block,'input_config');
        switch port_config
        case 'Simulink'
            switch input_config
            case 'Torque input - velocity output'
                blkID=1;
            case 'Velocity input - torque output'
                blkID=2;
            end
        case 'Two-way connection'
            switch input_config
            case 'Torque input - velocity output'
                blkID=3;
            case 'Velocity input - torque output'
                blkID=4;
            end
        end
        BlockOptions=cell(length(BlockNames),2);
        for idx=1:length(BlockNames)
            BlockOptions(idx,:)={['autolibdrivetraincommon/',BlockNames{idx}],BlockNames{idx}};
        end

        autoblksreplaceblock(block,BlockOptions,blkID);


        ParamList={'Nsp',[1,1],{'gt',0};...
        'Nsr',[1,1],{'gt',0};...
        'Js',[1,1],{'gt',0};...
        'Jp',[1,1],{'gt',0};...
        'Jp',[1,1],{'gt',0};...
        'Jc',[1,1],{'gt',0};...
        'bs',[1,1],{'gte',0};...
        'br',[1,1],{'gte',0};...
        'bp',[1,1],{'gte',0};...
        'bc',[1,1],{'gte',0};...
        'ws_o',[1,1],{};...
        'wc_o',[1,1],{};...
        };
        LookupTblList={};
        autoblkscheckparams(block,'Planetary Gear',ParamList,LookupTblList);
        varargout{1}=[];
    end
    if maskMode==2
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'0')
            port_config=get_param(block,'port_config');
            if strcmp(port_config,'Simulink')||strcmp(port_config,'Two-way connection')

            else

            end
        end
        varargout{1}=[];
    end
    if maskMode<8
        varargout{1}=[];
    end
    if maskMode==8
        varargout{1}=DrawCommands(block);
    end

end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'ws','SpdSun';'wc','SpdCarrier';...
    'wr','SpdRing';...
    'Ts','TrqSun';'Tc','TrqCarrier';'Tr','TrqRing';...
    'Info','Info';...
    };
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='planetary_gear.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,90,'white');
end