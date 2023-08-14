function[varargout]=autoblksclutch(varargin)



    block=varargin{1};
    maskMode=varargin{2};


    BlockNames={'Dry Clutch';...
    'Dry Clutch 2way'};
    BlockOptions=cell(length(BlockNames),2);
    for idx=1:length(BlockNames)
        BlockOptions(idx,:)={['autolibdrivetraincommon/',BlockNames{idx}],BlockNames{idx}};
    end
    if maskMode==0

        port_config=get_param(block,'port_config');
        input_config='Torque input - velocity output';
        switch port_config
        case 'Simulink'
            switch input_config
            case 'Torque input - velocity output'
                blkID=1;
            case 'Velocity input - torque output'
                blkID=3;
            end
        case 'Two-way connection'
            switch input_config
            case 'Torque input - velocity output'
                blkID=2;
            case 'Velocity input - torque output'
                blkID=4;
            end
        end


        autoblksreplaceblock(block,BlockOptions,blkID);


        ParamList={'Ndisk',[1,1],{'gt',0};...
        'Reff',[1,1],{'gt',0};...
        'Aeff',[1,1],{'gt',0};...
        'Jin',[1,1],{'gt',0};...
        'Jout',[1,1],{'gt',0};...
        'bin',[1,1],{'gte',0};...
        'bout',[1,1],{'gte',0};...
        'win_o',[1,1],{};...
        'wout_o',[1,1],{};...
        'mus',[1,1],{'gt',0};...
        'muk',[1,1],{'gt',0;'lt','mus'};...
        'tauC',[1,1],{'gte',0};...
        'Peng',[1,1],{'gte',0};...
        };
        LookupTblList={};
        autoblkscheckparams(block,'Ideal Clutch',ParamList,LookupTblList);
        initialLock=get_param(block,'InitiallyLocked');
        set_param([block,'/',BlockOptions{blkID,2}],'InitiallyLocked',initialLock);
        if blkID==2
            set_param([block,'/',BlockOptions{2,2},'/',BlockOptions{1,2}],'InitiallyLocked',initialLock);
        end
        varargout{1}=[];
    end
    if maskMode==1
        blkID=get_param(block,'blkID');
        if strcmp(blkID,'1')
            paramstruct=autoblkscheckparams(block,'Ideal Clutch',{'tauC',[1,1],{'gte',0}});
            if paramstruct.tauC<=0
                set_param([block,'/LPF'],'LabelModeActiveChoice','0');
            else
                set_param([block,'/LPF'],'LabelModeActiveChoice','1');
            end
        end
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
    port_config=get_param(BlkHdl,'port_config');
    switch port_config
    case 'Simulink'

        AliasNames={'P','Press';...
        'w1','SpdIn';'w2','SpdOut';...
        'T1','TrqIn';'T2','TrqOut';...
        'Info','Info'};

    case 'Two-way connection'
        AliasNames={'Info','Info';...
        'P','Press';...
        'B','B';'F','F'};

    end
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='ideal_clutch.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,90,'white');
end