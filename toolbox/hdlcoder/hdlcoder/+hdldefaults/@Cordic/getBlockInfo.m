function cordicInfo=getBlockInfo(this,slbh)









    cordicInfo.networkName=get_param(slbh,'Name');


    cordicInfo.iterNum=this.hdlslResolve('NumberOfIterations',slbh);


    rto=get_param(slbh,'RuntimeObject');
    fName=get_param(slbh,'Operator');
    getInfo=0;
    KnFactor=[];
    lutData=[];
    for ii=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(ii).Name,'KnFactor')
            KnFactor=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        elseif strcmp(rto.RuntimePrm(ii).Name,'lutData')
            lutData=rto.RuntimePrm(ii).Data;
            getInfo=getInfo+1;
        end
        if getInfo==2
            break;
        end
    end

    if(~(strcmpi(fName,'Atan2'))&&isempty(KnFactor))||isempty(lutData)
        error(message('hdlcoder:validate:MissingCordicParameter','SinCosCordic'));
    end


    cordicInfo.lutValue=lutData;


    cordicInfo.scaleFactor=KnFactor;
