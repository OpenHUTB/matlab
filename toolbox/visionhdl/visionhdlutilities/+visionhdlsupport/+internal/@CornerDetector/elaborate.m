function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);
    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    topNet=visionhdlsupport.internal.createNetworkWithComponent(hN,hC);
    topNet.addComment('Corner Detector');

    [inSig,outSig]=visionhdlsupport.internal.expandpixelcontrolbus(topNet);

    inportnames{1}='pixelIn';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';

    if strcmp(blockInfo.MinContrastSource,'Input port')&&~strcmp(blockInfo.Method,'Harris')
        inportnames{7}='minC';
    elseif strcmp(blockInfo.ThresholdSource,'Input port')&&strcmp(blockInfo.Method,'Harris')
        inportnames{7}='thresh';
    end

    outportnames{1}='Corner';
    IX=1;

    outportnames{IX+1}='hStartOut';
    outportnames{IX+2}='hEndOut';
    outportnames{IX+3}='vStartOut';
    outportnames{IX+4}='vEndOut';
    outportnames{IX+5}='validOut';


    for ii=1:numel(inportnames)
        inSig(ii).Name=inportnames{ii};
    end

    for ii=1:numel(outportnames)
        outSig(ii).Name=outportnames{ii};
    end

    dI=struct(inSig(1).Type);

    if isfield(dI,'Dimensions')
        inputDim=inSig(1).Type.Dimensions;
    else
        inputDim=1;
    end

    blockInfo.NumberOfPixels=inputDim;

    if blockInfo.NumberOfPixels==1

        this.elaborateCornerDetector(topNet,blockInfo,inSig,outSig);
    else
        this.elaborateMultiPixelCornerDetector(topNet,blockInfo,inSig,outSig);
    end


    nComp=pirelab.instantiateNetwork(hN,topNet,hCInSignal,hCOutSignal,hC.Name);


