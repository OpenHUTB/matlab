function[latency,fpDelays]=getscmLatency(~,hC,constMatrix,sharingFactor,nfpCustomLatency)




    [~,activeRowPositions,~]=sschdloptimizations.getActiveElements(constMatrix,sharingFactor);



    maxRowElements=0;
    for ii=1:numel(activeRowPositions)
        rowElements=activeRowPositions{ii};
        if(numel(rowElements)>maxRowElements)
            maxRowElements=numel(rowElements);
        end
    end


    maxAdderTreeStages=0;
    if(maxRowElements>0)
        maxAdderTreeStages=ceil(log2(maxRowElements));
    end


    outSignals=hC.PirOutputSignals;
    outSignalsType=getPirSignalLeafType(outSignals.Type);
    if outSignalsType.isSingleType
        targetCompDataType='SINGLE';
    elseif outSignalsType.isHalfType
        targetCompDataType='HALF';
    else
        targetCompDataType='DOUBLE';
    end


    mulLatency=resolveLatencyForIPType(hC,targetCompDataType,'MUL');
    addLatency=resolveLatencyForIPType(hC,targetCompDataType,'ADDSUB');

    if nfpCustomLatency>=0
        mulLatency=nfpCustomLatency;
        addLatency=nfpCustomLatency;
    end

    if((mulLatency==-1)||(addLatency==-1))
        latency=-1;
        return;
    end



    latency=double(mulLatency+maxAdderTreeStages*addLatency);


    fpDelays=latency;


    if sharingFactor>1
        latency=ceil(latency./sharingFactor)+2;
    end
end

function latency=resolveLatencyForIPType(hC,targetCompDataType,targetIPType)


    hDriver=hdlcurrentdriver;

    p=pir(hC.Owner.getCtxName);
    targetDriver=hDriver.getTargetCodeGenDriver(p);

    if isempty(targetDriver)||~strcmpi(class(targetDriver),'targetcodegen.nfpdriver')
        latency=-1;
    else
        latency=targetDriver.getDefaultLatency(targetIPType,targetCompDataType,[]);
    end
end