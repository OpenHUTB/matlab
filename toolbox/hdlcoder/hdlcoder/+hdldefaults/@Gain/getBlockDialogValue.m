function[cval,nfpOptions,TunableParamStr,TunableParamType]=...
    getBlockDialogValue(this,slbh)


    gain_value=get_param(slbh,'Gain');
    nfpOptions=[];
    TunableParamStr=[];
    TunableParamType=[];

    rto=get_param(slbh,'RuntimeObject');
    gainloc=0;
    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,'Gain')
            gainloc=n;
            break;
        end
    end
    if gainloc==0
        error(message('hdlcoder:validate:gainparameternotfound'));
    end

    cval=rto.RuntimePrm(gainloc).Data;

    if isempty(cval)
        error(message('hdlcoder:validate:gainparameterempty'));
    end

    if nargout>1

        nfpOptions=getNFPBlockInfo(this);
        nfpMantMulStr=getImplParams(this,'MantissaMultiplyStrategy');
        nfpOptions.MantMul=int8(0);
        if isempty(nfpMantMulStr)
            nfpOptions.MantMul=int8(0);
        elseif strcmpi(nfpMantMulStr,'FullMultiplier')
            nfpOptions.MantMul=int8(1);
        elseif strcmpi(nfpMantMulStr,'PartMultiplierPartAddShift')
            nfpOptions.MantMul=int8(2);
        elseif strcmpi(nfpMantMulStr,'NoMultiplierFullAddShift')
            nfpOptions.MantMul=int8(3);
        end

        if nargout>2

            [TunableParamStr,v]=...
            hdlimplbase.EmlImplBase.getTunableParameter(slbh,gain_value);
            if~isempty(v)
                hdlDriver=hdlcurrentdriver;
                check=struct('path',getfullname(slbh),...
                'type','block',...
                'message',v.Message,...
                'level','Error',...
                'MessageID',v.MessageID);
                hdlDriver.updateChecksCatalog(hdlDriver.ModelName,check);
            end

            if~isempty(TunableParamStr)
                isComplex=~isreal(cval);
                multMode=get_param(slbh,'Multiplication');
                if~isscalar(cval)&&~strcmpi(multMode,'Element-wise(K.*u)')

                    portDims=size(cval);
                else

                    portDims=numel(cval);
                end
                TunableParamType=...
                getpirsignaltype(rto.RuntimePrm(gainloc).Datatype,isComplex,portDims);
            end
        end
    end
end
