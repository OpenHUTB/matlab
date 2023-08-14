function[TunableParamInputs,TunableParamStrs,TunableParamTypes]=...
    getTunableProperty(this,slbh)%#ok<INUSL>



    TunableParamStrs={};
    TunableParamTypes=[];
    TunableParamInputs=struct;

    rto=get(slbh,'RunTimeObject');
    numRTPs=rto.NumRunTimePrms;

    for ii=1:numRTPs
        rtp=rto.RuntimePrm(ii);
        param=get_param(slbh,rtp.Name);
        TunableParamStr=hdlbuiltinimpl.EmlImplBase.getTunableParameter(slbh,param);

        if~isempty(TunableParamStr)
            TunableParamInputs.(rtp.Name)=TunableParamStr;

            idx=find(strcmp(TunableParamStrs,TunableParamStr),1,'first');
            if~isempty(idx)



                continue;
            end

            TunableParamStrs{end+1}=TunableParamStr;%#ok<*AGROW>

            sigType=rtp.Datatype;
            isComplex=0;
            if strcmp(rtp.Complexity,'Complex')
                isComplex=1;
            end
            portDims=rtp.Dimensions;

            TunableParamType=getpirsignaltype(sigType,isComplex,portDims);
            TunableParamTypes=[TunableParamTypes,TunableParamType];
        else
            warning(message('hdlcoder:validate:SimulinkParamUsage',rtp.Name,getfullname(slbh)));
        end
    end

end
