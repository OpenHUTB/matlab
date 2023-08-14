function cordicInfo=getBlockInfo(this,slbh)









    cordicInfo.networkName=get_param(slbh,'Name');


    cordicInfo.iterNum=this.hdlslResolve('NumberOfIterations',slbh);


    rto=get_param(slbh,'RuntimeObject');
    getInfo=0;
    for ii=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(ii).Name,'KnFactor')
            KnFactor=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        elseif strcmp(rto.RuntimePrm(ii).Name,'lutData')
            lutData=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end
        if(getInfo==2)
            break;
        end
    end

    if isempty(KnFactor)||isempty(lutData)
        error(message('hdlcoder:validate:MissingCordicParameter','Pol2CartCordic'));
    end


    cordicInfo.lutValue=lutData;


    if strcmpi(get_param(slbh,'ScaleReciprocalGainFactor'),'on')
        cordicInfo.scaleFactor=KnFactor;
    else
        cordicInfo.scaleFactor=1;
    end




