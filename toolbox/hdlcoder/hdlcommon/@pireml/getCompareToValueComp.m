function cgirComp=getCompareToValueComp(hN,hSignalsIn,hSignalsOut,opName,constVal,compName)






    if(nargin<6)
        compName='compare';
    end

    switch opName
    case '=='
        mode=1;
    case '~='
        mode=2;
    case '<='
        mode=3;
    case '<'
        mode=4;
    case '>='
        mode=5;
    case '>'
        mode=6;
    otherwise
        error(message('hdlcommon:hdlcommon:NotSupportedOp',opName));
    end

    compVal=pirelab.getTypeInfoAsFi(hSignalsIn.Type,'Nearest','Saturate',constVal);
    [dimlen,outType]=pirelab.getVectorTypeInfo(hSignalsOut);

    if(outType.is1BitType)
        cgirComp=createEmlComp(hN,hSignalsIn,hSignalsOut,mode,compVal,compName);
    else
        if dimlen==1
            hT=pir_boolean_t;
        else
            hT=pirelab.getPirVectorType(pir_boolean_t,dimlen);
        end
        hCmpOut=hN.addSignal(hT,sprintf('%s_cmpOut',compName));
        cgirComp=createEmlComp(hN,hSignalsIn,hCmpOut,mode,compVal,compName);
        pireml.getDTCComp(hN,hCmpOut,hSignalsOut,'Nearest','Saturate');
    end


end

function cgirComp=createEmlComp(hN,hSignalsIn,hCmpOut,mode,compVal,compName)


    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hSignalsIn,...
    'OutputSignals',hCmpOut,...
    'EMLFileName','hdleml_comparetovalue',...
    'EMLParams',{mode,compVal},...
    'EMLFlag_RunLoopUnrolling',false);

    if targetmapping.isValidDataType(hSignalsIn(1).Type)
        cgirComp.setSupportTargetCodGenWithoutMapping(true);
    end

end


