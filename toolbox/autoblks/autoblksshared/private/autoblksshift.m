function[varargout]=autoblksshift(varargin)




    varargout{1}=0;
    Block=varargin{1};

    if autoblkschecksimstopped(Block)
        switch varargin{2}
        case 'PRNDL'
            prndl(Block)
        case 'MaxPower'
            maxPwr(Block)
        case 'EditUpLut'
            editLut(Block,'upshift')
        case 'EditDnLut'
            editLut(Block,'downshift')
        case 'EditPwrLut'
            editLut(Block,'maxPower')
        end
    end
end

function prndl(Block)
    minNgrs=-2;
    maxNgrs=80;

    ParamList={'GearInit',[1,1],{'gte',minNgrs;'int',0;'lte',maxNgrs};...
    'LugSpd',[1,1],{'gte',-100};...
    'MinUpSpd',[1,1],{'gte',-100};...
    'tClutchUp',[1,1],{'gte',0;'lte',120};...
    'tClutchDn',[1,1],{'gte',0;'lte',120};...
    'UpShSpd',[],{'gte',-100;'lte',300}
    'UpLdBpt',[],{'gte',0;'lte',1}};
    autoblkscheckparams(Block,'',ParamList);

    autoblksgetmaskparms(Block,{'UpShSpd','Ngears','POFS','GOFS'},true);
    upShSize=size(UpShSpd);
    ParamList={'DnShSpd',[upShSize(1),upShSize(2)],{'gte',-100;'lte',300}
    'DnLdBpt',[],{'gte',0;'lte',1}};
    autoblkscheckparams(Block,'',ParamList);

    maskObj=Simulink.Mask.get(Block);
    fwrGears=upShSize(2)+1;
    parmGears=maskObj.getParameter('Ngears');
    if Ngears~=fwrGears
        parmGears.Value=num2str(fwrGears);
    end

    upShBpt=maskObj.getParameter('UpShBpt');
    upShBpt2=['1:',num2str(fwrGears-1)];
    if~strcmp(upShBpt.Value,upShBpt2)
        upShBpt.Value=upShBpt2;
    end
    dnShBpt=maskObj.getParameter('DnShBpt');
    dnShBpt2=['2:',num2str(fwrGears)];
    if~strcmp(dnShBpt.Value,dnShBpt2)
        dnShBpt.Value=dnShBpt2;
    end

    if upShSize(1)~=length(POFS)
        mPofs=maskObj.getParameter('POFS');
        mPofs.Value=['zeros(',num2str(upShSize(1)),',1)'];
    end
    if upShSize(2)~=length(GOFS)
        mGofs=maskObj.getParameter('GOFS');
        mGofs.Value=['zeros(1,',num2str(upShSize(2)),')'];
    end
end

function maxPwr(Block)
    minNgrs=2;
    maxNgrs=20;

    ParamList={'Ngears',[1,1],{'gte',minNgrs;'int',0;'lte',maxNgrs};...
    'VehSpdBpt',[],{'gte',-100;'lte',300}
    'TWAITup',[1,1],{'gte',0;'lte',2};...
    'TWAITdn',[1,1],{'gte',0;'lte',2}};
    autoblkscheckparams(Block,'',ParamList);
    maskObj=Simulink.Mask.get(Block);
    autoblksgetmaskparms(Block,{'Ngears','VehSpdBpt','PmaxFrc','PmaxFrc_'},true);

    grBpt=['1:',num2str(Ngears)];
    gearBpt=maskObj.getParameter('GearBpt');
    if~strcmp(gearBpt.Value,grBpt)
        gearBpt.Value=grBpt;
    end
    pMax1s=maskObj.getParameter('PmaxFrc_');
    pwrsize=size(PmaxFrc);
    lenSpdBpt=length(VehSpdBpt);
    if Ngears~=size(PmaxFrc_,1)||lenSpdBpt~=size(PmaxFrc_,2)
        pMax1s.Value=['ones(',num2str(pwrsize(1)),',',num2str(pwrsize(2)),')'];
    end

    if Ngears~=pwrsize(1)||lenSpdBpt~=pwrsize(2)
        ParamList={'PmaxFrc_',[Ngears,lenSpdBpt],{'gte',0;'lte',1}};
        autoblkscheckparams(Block,'',ParamList);
    end

    selecIndx=maskObj.getParameter('SelecIndx');
    sIndx=['ones(',num2str(Ngears),',1)'];
    if~strcmp(selecIndx.Value,sIndx)
        selecIndx.Value=sIndx;
    end
end

function editLut(Block,lut)
    maskObj=Simulink.Mask.get(Block);
    if strcmp(lut,'upshift')
        shLut=maskObj.getDialogControl('UpShLut');
    elseif strcmp(lut,'downshift')
        shLut=maskObj.getDialogControl('DnShLut');
    elseif strcmp(lut,'maxPower')
        shLut=maskObj.getDialogControl('PwrFrcLut');
    end
    if strcmp(shLut.Visible,'off')
        shLut.Visible='on';
    elseif strcmp(shLut.Visible,'on')
        shLut.Visible='off';
    end
end