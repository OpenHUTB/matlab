function[varargout]=autoblksdiffas(varargin)



    block=varargin{1};
    maskMode=varargin{2};
    maskObj=Simulink.Mask.get(block);
    popupObj=maskObj.getParameter('shaftSwitchMask');

    couplingType=get_param(block,'couplingType');
    shaftSwitch=get_param(block,'shaftSwitchMask');
    BlockNames={'Active Slip Differential Superposition';'Active Slip Differential Stationary'};













    if maskMode==0
        [~]=autoblksdiffas(block,'1');
        diffType=get_param(block,'diffType');
        DiffActSlipOptions=...
        {['autolibshareddrivetraincommon/',BlockNames{1}],BlockNames{1};...
        ['autolibshareddrivetraincommon/',BlockNames{2}],BlockNames{2}};
        switch diffType
        case 'Spur gears, superposition clutches'
            blkID=1;

            ParamList={'Ndiff',[1,1],{'gt',0};...
            'Jd',[1,1],{'gt',0};...
            'bd',[1,1],{'gte',0};...
            'Jw1',[1,1],{'gt',0};...
            'bw1',[1,1],{'gte',0};...
            'Jw2',[1,1],{'gt',0};...
            'bw2',[1,1],{'gte',0};...
            'omegaw1o',[1,1],{'lte',5e3};...
            'omegaw2o',[1,1],{'lte',5e3};...
            'maxAbsSpd',[1,1],{'gt',0};...
            'Aeff',[1,1],{'gt',0};...
            'Reff',[1,1],{'gt',0};...
            'Ndisks',[1,1],{'gt',0;'int',0};...
            'Fc',[1,1],{};...
            'tauC',[1,1],{'gt',0};...
            'Jgc',[1,1],{'gt',0};...
            'Ns1',[1,1],{'gt',0};...
            'Ns2',[1,1],{'gt',0};...
            };
        case 'Double planetary gears, stationary clutches'
            blkID=2;
            ParamList={'Ndiff',[1,1],{'gt',0};...
            'Jd',[1,1],{'gt',0};...
            'bd',[1,1],{'gte',0};...
            'Jw1',[1,1],{'gt',0};...
            'bw1',[1,1],{'gte',0};...
            'Jw2',[1,1],{'gt',0};...
            'bw2',[1,1],{'gt',0};...
            'omegaw1o',[1,1],{'lte',5e3};...
            'omegaw2o',[1,1],{'lte',5e3};...
            'maxAbsSpd',[1,1],{'gt',0};...
            'Aeff',[1,1],{'gt',0};...
            'Reff',[1,1],{'gt',0};...
            'Ndisks',[1,1],{'gt',0;'int',0};...
            'Fc',[1,1],{};...
            'tauC',[1,1],{'gt',0};...
            'Js1',[1,1],{'gt',0};...
            'Jc1',[1,1],{'gt',0};...
            'Jr1',[1,1],{'gt',0};...
            'Js2',[1,1],{'gt',0};...
            'Jc2',[1,1],{'gt',0};...
            'Jr2',[1,1],{'gt',0};...
            'Np1',[1,1],{'gt',0};...
            'Np2',[1,1],{'gt',0};...
            };
        end
        IdealFrictionChecks={{'dw',{}},'muc',{'gte',0}};
        MappedClutchTblBpt={'pT',{'gte',0;'lte',1e7},'dwT',{'gte',-1e5;'lte',1e5}};
        ClutchTableChecks={MappedClutchTblBpt,'TdPdw',{'gte',-1e6;'lte',1e6}};
        TableList=[IdealFrictionChecks;ClutchTableChecks];
        autoblksreplaceblock(block,DiffActSlipOptions,blkID);
        autoblkscheckparams(block,ParamList,TableList);


        interpType=maskObj.getParameter('IdealInterpMethod');
        extrapType=maskObj.getParameter('IdealExtrapMethod');
        set_param([block,'/',DiffActSlipOptions{blkID,2}],'IdealInterpMethod',interpType.Value);
        set_param([block,'/',DiffActSlipOptions{blkID,2}],'IdealExtrapMethod',extrapType.Value);


        if strcmp(shaftSwitch,popupObj.TypeOptions{2})
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'shaftSwitchMask',shaftSwitch)
            shaftSwitch=false;
            varargout{1}=shaftSwitch;
        else
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'shaftSwitchMask',shaftSwitch)
            shaftSwitch=true;
            varargout{1}=shaftSwitch;
        end


        set_param([block,'/',DiffActSlipOptions{blkID,2}],'couplingType',couplingType)
        switch couplingType
        case 'Pre-loaded ideal clutch'

            if~strcmp(get_param([block,'/',DiffActSlipOptions{blkID,2},'/Coupling Torque'],'LabelModeActiveChoice'),'0')
                set_param([block,'/',DiffActSlipOptions{blkID,2},'/Coupling Torque'],'LabelModeActiveChoice','0');
            end

            interpType=maskObj.getParameter('IdealInterpMethod');
            extrapType=maskObj.getParameter('IdealExtrapMethod');
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'IdealInterpMethod',interpType.Value);
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'IdealExtrapMethod',extrapType.Value);

        case 'Slip speed dependent torque data'

            if~strcmp(get_param([block,'/',DiffActSlipOptions{blkID,2},'/Coupling Torque'],'LabelModeActiveChoice'),'1')
                set_param([block,'/',DiffActSlipOptions{blkID,2},'/Coupling Torque'],'LabelModeActiveChoice','1');
            end


            interpType=maskObj.getParameter('TdwInterpMethod');
            extrapType=maskObj.getParameter('TdwExtrapMethod');
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'TdwInterpMethod',interpType.Value);
            set_param([block,'/',DiffActSlipOptions{blkID,2}],'TdwExtrapMethod',extrapType.Value);


            varargout{1}=[];
        end
    end
    if maskMode==1
        diffType=get_param(block,'diffType');
        switch diffType
        case 'Spur gears, superposition clutches'
            autoblksenableparameters(block,[],[],{'superParams'},{'stationParams'});

        case 'Double planetary gears, stationary clutches'
            autoblksenableparameters(block,[],[],{'stationParams'},{'superParams'});
        end
        varargout{1}=[];

    end
    if maskMode==2||maskMode==4
        switch couplingType
        case 'Pre-loaded ideal clutch'
            autoblksenableparameters(block,[],[],'IdealClutch');
            autoblksenableparameters(block,[],[],[],'SlipSpdData');

        case 'Slip speed dependent torque data'
            autoblksenableparameters(block,[],[],'SlipSpdData');
            autoblksenableparameters(block,[],[],[],'IdealClutch');
        end

        varargout{1}=[];
    end
    if maskMode==8
        varargout{1}=DrawCommands(block);
    else
        varargout{1}=[];
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'DriveshftSpd','DriveshftSpd';...
    'Prs1','Prs1';'Prs2','Prs2';...
    'Axl1Trq','Axl1Trq';'Axl2Trq','Axl2Trq';...
    'Axl1Spd','Axl1Spd';'Axl2Spd','Axl2Spd';...
    'DriveshftTrq','DriveshftTrq'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='differential_asd.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,10,'white');
end