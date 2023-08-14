function bcc=getBCCDefaultAdd(customLayerList,kernelDataType,RoundingMode)




    if(nargin<1)
        customLayerList=[];
    end

    if(nargin<2)
        kernelDataType='single';
    end

    if(nargin<3)
        RoundingMode='Round';
    end


    bcc.kernelDataType=kernelDataType;




    bcc.SumLatency=3;




    bcc.ProdLatency=3;
    bcc.CmpLatency=1;


    bcc.inputMemDepthLimit=10;
    bcc.resultMemDepthLimit=120;


    bcc.inputBurstLength=bcc.inputMemDepthLimit/2;
    bcc.outputBurstLength=floor(min(bcc.inputMemDepthLimit,bcc.resultMemDepthLimit)/2);

    bcc.RoundingMode=RoundingMode;


    bcc.lcParams={};



    lcParams.name='inputsLength';
    lcParams.dataType='uint32';
    lcParams.vectorType=2;
    bcc.lcParams{end+1}=lcParams;


    lcParams.name='outputLength';
    lcParams.dataType='uint32';
    lcParams.vectorType=1;
    bcc.lcParams{end+1}=lcParams;


    lcParams.name='numInputs';
    lcParams.dataType='fixdt(0,2,0)';
    lcParams.vectorType=1;
    bcc.lcParams{end+1}=lcParams;


    lcParams.name='reluMode';
    lcParams.dataType='fixdt(0,3,0)';
    lcParams.vectorType=1;
    bcc.lcParams{end+1}=lcParams;




    lcParams.name='layerMode';
    lcParams.dataType='uint8';
    lcParams.vectorType=1;
    bcc.lcParams{end+1}=lcParams;



    if isempty(customLayerList)
        pvList=[];
    else
        pvList=[customLayerList.PropertyValueList];
    end
    for pvPair=pvList
        value=pvPair.value;
        lcParams.name=pvPair.property;
        lcParams.dataType=class(value);
        lcParams.vectorType=numel(value);
        bcc.lcParams{end+1}=lcParams;
    end


    bcc.halfProgLCFIFODepth=numel(bcc.lcParams)*3;
    lcParams=cell2mat(bcc.lcParams);
    bcc.layerConfigNumWLimit=sum([lcParams.vectorType]);

end


