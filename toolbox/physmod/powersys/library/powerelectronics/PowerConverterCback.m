function[BlockChoice,Ts,BLK]=PowerConverterCback(varargin)






    block=varargin{1};

    if nargin==1
        BLK=[];
    else
        BLK.Ron=varargin{2};
        BLK.Rs=varargin{3};
        BLK.Cs=varargin{4};
        BLK.Vforward=varargin{5};
        BLK.Ron_Diode=varargin{6};
        BLK.Rs_Diode=varargin{7};
        BLK.Cs_Diode=varargin{8};
        BLK.Vf_Diode=varargin{9};
        BLK.Rs_CurrentSource=varargin{10};
        BLK.Ron_ACsource=varargin{11};
    end

    sys=bdroot(block);
    PowerguiInfo=getPowerguiInfo(sys,block);
    Ts=PowerguiInfo.Ts;

    MaskObj=Simulink.Mask.get(block);
    ADVANCED=MaskObj.getDialogControl('Advanced');
    BASIC=MaskObj.getDialogControl('Basic');

    Parameters=Simulink.Mask.get(block).Parameters;
    Ron_ACsource=strcmp(get_param(block,'MaskNames'),'Ron_ACsource')==1;
    Ron_Diode=strcmp(get_param(block,'MaskNames'),'Ron_Diode')==1;
    Rs_Diode=strcmp(get_param(block,'MaskNames'),'Rs_Diode')==1;
    Cs_Diode=strcmp(get_param(block,'MaskNames'),'Cs_Diode')==1;
    Vf_Diode=strcmp(get_param(block,'MaskNames'),'Vf_Diode')==1;

    switch get_param(block,'ModelType')
    case{1,'Switching devices'}
        ADVANCED.Visible='off';
        BASIC.Visible='on';
        BlockChoice='SwitchingDevices';
    case{2,'Switching function'}
        ADVANCED.Visible='on';
        BASIC.Visible='off';
        Parameters(Ron_Diode).Visible='on';
        Parameters(Rs_Diode).Visible='on';
        Parameters(Cs_Diode).Visible='on';
        Parameters(Vf_Diode).Visible='on';
        Parameters(Ron_ACsource).Visible='off';
        if Ts==0
            BlockChoice='SwitchingFunctionContinuous';
        else
            BlockChoice='SwitchingFunctionDiscrete';
        end
    case{3,'Average model (Uref-controlled)','Average model (D-controlled)'}
        ADVANCED.Visible='on';
        BASIC.Visible='off';
        Parameters(Ron_Diode).Visible='on';
        Parameters(Rs_Diode).Visible='on';
        Parameters(Cs_Diode).Visible='on';
        Parameters(Vf_Diode).Visible='on';
        Parameters(Ron_ACsource).Visible='off';
        if Ts==0
            BlockChoice='AverageContinuous';
        else
            BlockChoice='AverageDiscrete';
        end
    case{4,'Average model (No rectifier mode)'}
        ADVANCED.Visible='on';
        BASIC.Visible='off';
        Parameters(Ron_Diode).Visible='off';
        Parameters(Rs_Diode).Visible='off';
        Parameters(Cs_Diode).Visible='off';
        Parameters(Vf_Diode).Visible='off';
        Parameters(Ron_ACsource).Visible='on';
        if Ts==0
            BlockChoice='AverageNoRectifierContinuous';
        else
            BlockChoice='AverageNoRectifierDiscrete';
        end
    end

    ME=get_param(block,'MaskEnables');
    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        ME{3}='off';
        ME{4}='off';
        ME{7}='off';
        ME{8}='off';
    else
        ME{3}='on';
        ME{4}='on';
        ME{7}='on';
        ME{8}='on';
    end
    set_param(block,'MaskEnables',ME);