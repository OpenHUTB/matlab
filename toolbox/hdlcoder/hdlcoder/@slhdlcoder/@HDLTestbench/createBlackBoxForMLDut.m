


function[inData,outData,hInst]=createBlackBoxForMLDut(this,topN,dutname,...
    hCgInfo,globalSigs)


    hdlDutPorts=hCgInfo.hdlDutPortInfo;
    inPorts=hdlDutPorts(arrayfun(@(x)strcmp(x.Direction,'Input'),hdlDutPorts));
    numPorts=numel(inPorts);
    inData=hdlhandles(1,numPorts);
    inportNames=cell(1,numPorts);
    bitT=topN.getType('Logic','WordLength',1);

    for ii=1:numPorts
        inportNames{ii}=inPorts(ii).Name;
        if strcmp(inPorts(ii).Kind,'data')

            hT=createTypeFromTypeInfo(inPorts(ii).TypeInfo,topN);
            hS=topN.addSignal(hT,inPorts(ii).Name);
            inData(ii)=hS;
        else
            switch inPorts(ii).Kind
            case 'clock'
                hS=globalSigs(1);
            case 'reset'
                hS=globalSigs(2);
            case 'clock_enable'
                hS=topN.findSignal('name',inPorts(ii).Name);
                if isempty(hS)
                    hS=topN.addSignal(bitT,inPorts(ii).Name);
                end
                if globalSigs(3)~=hS


                    pirelab.getWireComp(topN,globalSigs(3),hS);
                end
            otherwise
            end
        end
        inData(ii)=hS;
    end

    outPorts=hdlDutPorts(arrayfun(@(x)strcmp(x.Direction,'Output'),hdlDutPorts));
    numPorts=numel(outPorts);
    outportNames=cell(1,numPorts);
    outData=hdlhandles(1,numPorts);
    for ii=1:numPorts
        outportNames{ii}=outPorts(ii).Name;
        hT=createTypeFromTypeInfo(outPorts(ii).TypeInfo,topN);
        outData(ii)=topN.addSignal(hT,outPorts(ii).Name);
    end

    hInst=pirelab.getInstantiationComp('Network',topN,...
    'Name',dutname,'EntityName',dutname,...
    'InportNames',inportNames,'OutportNames',outportNames,...
    'InportSignals',inData,'OutportSignals',outData,...
    'AddClockPort','off','AddClockEnablePort','off','AddResetPort','off');
end

function hT=createTypeFromTypeInfo(typeInfo,hN)
    baseT=pirelab.convertSLType2PirType(typeInfo.sltype);
    if~typeInfo.isscalar
        hT=hN.getType('Array','Dimensions',typeInfo.dims,'BaseType',baseT);
    else
        hT=baseT;
    end
end
