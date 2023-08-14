function[dtiInfo,nfpOptions]=getBlockInfo(this,slbh)

















    dtiInfo.intMethod=get_param(slbh,'IntegratorMethod');


    gainValue=[];
    upperSatLimit=[];
    lowerSatLimit=[];


    rto=get_param(slbh,'RuntimeObject');
    getInfo=0;
    for ii=1:rto.NumRuntimePrms
        if~isempty(rto.RuntimePrm(ii))&&strcmp(rto.RuntimePrm(ii).Name,'InitialCondition')
            initC=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end
        if~isempty(rto.RuntimePrm(ii))&&strcmp(rto.RuntimePrm(ii).Name,'gainval')

            gainValue=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end
        if~isempty(rto.RuntimePrm(ii))&&strcmp(rto.RuntimePrm(ii).Name,'UpperSaturationLimit')
            upperSatLimit=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end

        if~isempty(rto.RuntimePrm(ii))&&strcmp(rto.RuntimePrm(ii).Name,'LowerSaturationLimit')
            lowerSatLimit=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end
        if(getInfo==4)
            break;
        end
    end


    limitOutput=get_param(slbh,'LimitOutput');
    if isempty(initC)
        error(message('hdlcoder:validate:MissingDTIParameter'));
    end


    dtiInfo.initC=initC;



    if isempty(gainValue)
        dtiInfo.isGainValueEqualToOne=true;
    else
        dtiInfo.isGainValueEqualToOne=false;
    end
    dtiInfo.gainValue=gainValue;


    if strcmpi(limitOutput,'on')
        if isempty(upperSatLimit)&&isempty(lowerSatLimit)

            dtiInfo.applySatLimit=false;
        else
            dtiInfo.applySatLimit=true;
        end
    else
        dtiInfo.applySatLimit=false;
    end
    dtiInfo.upperSatLimit=upperSatLimit;
    dtiInfo.lowerSatLimit=lowerSatLimit;


    dtiInfo.initCMode=get_param(slbh,'InitialConditionMode');


    dtiInfo.rndMode=get_param(slbh,'RndMeth');
    dtiInfo.satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');
    if dtiInfo.satMode
        dtiInfo.satMode='Saturate';
    end


    dtiInfo.compName=get_param(slbh,'Name');




    dtiInfo.externalReset=get_param(slbh,'ExternalReset');

    nfpOptions=this.getNFPBlockInfo;
end


