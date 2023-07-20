function tOutType=getStageOutputType(tInType,opName,stageInputSignalsType,hOutputType,signs)




    if(nargin<3)
        stageInputSignalsType='';
    end

    if(nargin<4)
        hOutputType=tInType;
    end

    if(nargin<5)
        signs='++';
    end

    if strcmpi(opName,'sum')
        tOutType=getOutputType(tInType,stageInputSignalsType,hOutputType,signs);
    elseif strcmpi(opName,'min')||strcmpi(opName,'max')

        tOutType=tInType;
    else
        error(message('hdlcoder:validate:treeunsupported',opName));
    end

end

function stageOutType=getOutputType(tInType,stageInputSignalsType,hOutputType,signs)

    cplx=false;
    isArray=false;


    if tInType.isArrayType
        isArray=true;
        dimLen=pirelab.getVectorTypeInfo(tInType,true);
    end


    if(pirelab.hasComplexType(hOutputType))
        cplx=true;
    end

    if isArray||cplx
        tInType=tInType.getLeafType;
    end

    if tInType.isFloatType
        stageOutType=hOutputType;
        return;
    end

    if~isempty(stageInputSignalsType)

        in1Type=stageInputSignalsType(1);
        in2Type=stageInputSignalsType(2);
        if isArray||cplx
            in1Type=in1Type.getLeafType;
            in2Type=in2Type.getLeafType;
        end






        w1=in1Type.WordLength;
        w2=in2Type.WordLength;
        if(w1==128||w2==128)
            stageOutType=tInType;
        else
            f1=-in1Type.FractionLength;
            f2=-in2Type.FractionLength;

            isSigned=in1Type.Signed||in2Type.Signed;




            if(signs(1)=='-'||sign(2)=='-')
                isSigned=1;
            end
            Isum=max(w1-f1,w2-f2)+1-isSigned;
            fracLength=-max(f1,f2);
            wordLength=isSigned+Isum+max(f1,f2);
            if wordLength>=128


                stageOutType=hOutputType;
                return;
            else
                stageOutType=pir_fixpt_t(isSigned,wordLength,fracLength);
            end
        end
    else

        if tInType.WordLength==128
            stageOutType=tInType;
        else
            isSigned=tInType.Signed;
            wordLength=tInType.WordLength+1;
            fracLength=tInType.FractionLength;
            stageOutType=pir_fixpt_t(isSigned,wordLength,fracLength);
        end
    end

    if(cplx)
        stageOutType=pir_complex_t(stageOutType);
    end

    if isArray
        stageOutType=pirelab.createPirArrayType(stageOutType,dimLen);
    end
end

