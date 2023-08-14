function v=validateBlock(~,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

    rto=get_param(bfp,'runtimeobject');
    threshold=0;
    for n=1:rto.NumRuntimePrms
        if strcmp(rto.RuntimePrm(n).Name,'Threshold')
            threshold=rto.RuntimePrm(n).Data;
            if isempty(threshold)
                threshold=0;
            end
            threshold=double(threshold);
            break;
        end
    end

    sig1=hC.PirInputPorts(1).Signal;
    sig2=hC.PirInputPorts(3).Signal;
    ctrl=hC.PirInputPorts(2).Signal;
    out=hC.PirOutputPorts(1).Signal;
    criteria=get_param(bfp,'Criteria');
    cType=ctrl.Type;
    if~cType.isBooleanType&&~cType.isFloatType...
        &&~cType.isArrayType&&~cType.isEnumType
        if cType.isUnsignedType&&any(threshold==0)&&strcmpi(criteria,'u2 >= Threshold')
            v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:badswitchselthresh'));
        elseif cType.WordLength==1&&cType.Signed==0
            if~strcmpi(criteria,'u2 ~= 0')
                maskThreshold=slResolve(get_param(bfp,'Threshold'),bfp);
                if threshold~=maskThreshold
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedufix1threshold'));
                end
            end
        end
    end

    nfpMode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    isCtrlFloatingPt=cType.getLeafType().isFloatType();
    if(nfpMode&&isCtrlFloatingPt)||targetmapping.mode(out)


        if~strcmpi(criteria,'u2 ~= 0')&&~(cType.isBooleanType&&...
            strcmpi(criteria,'u2 > Threshold')&&(threshold==0))
            if(nfpMode)
                if(isCtrlFloatingPt)
                    v(end+1)=hdlvalidatestruct(2,message('hdlcommon:nativefloatingpoint:InefficientSwitchCriteria'));
                end
            else
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:IllegalSwitchCriteria'));
            end
        end
    end

    isdouble=hdlsignalisdouble([sig1,sig2,out]);
    if any(isdouble==true)&&any(isdouble==false)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixeddoubleUnhandled'));
    end


    complex1=hdlsignaliscomplex(sig1);
    complex2=hdlsignaliscomplex(sig2);
    complexout=hdlsignaliscomplex(out);
    if~((complex1&&complex2&&complexout)||...
        (~complex1&&~complex2&&~complexout))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mixedrealcomplex'));
    end



    vecc=hdlsignalvector(ctrl);
    if(all(vecc==0))
        vecc=1;
    end
    vecc=max(vecc);


    vecthreshold=max(size(threshold));

    if(vecthreshold~=1&&...
        ~isequal(vecc,vecthreshold))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:controlthresholdmismatch'));
    end



