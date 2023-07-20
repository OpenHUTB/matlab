function[varargout]=autoblksdiffals(varargin)



    Block=varargin{1};
    maskMode=varargin{2};
    shaftSwitch=get_param(Block,'shaftSwitchMask');
    if maskMode==0
        DiffOpenOptions=...
        {'autolibdrivetraincommon/Open Differential','Open Differential';
        'autolibdrivetraincommon/Open Differential SSC','Open Differential SSC'};

        port_config=get_param(Block,'port_config');

        switch port_config
        case 'Simulink'
            autoblksreplaceblock(Block,DiffOpenOptions,1);
            set_param([Block,'/Open Differential'],'shaftSwitchMask',shaftSwitch)
        case 'Simscape'
            autoblksreplaceblock(Block,DiffOpenOptions,2);
            set_param([Block,'/Open Differential SSC'],'shaftSwitchMask',shaftSwitch)
        end
    end

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
    };

    autoblkscheckparams(Block,'Open Differential',ParamList);

    if strcmp(shaftSwitch,'To the right of center-line')
        shaftSwitch=false;
    else
        shaftSwitch=true;
    end
    varargout{1}=shaftSwitch;

end