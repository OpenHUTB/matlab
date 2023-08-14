classdef deployableNetwork<handle




    properties(GetAccess=public,SetAccess=protected)

        DDROffsetTable=[];



        InputFrameNumberLimit=1;
        CnnProcessor;
        outputComponentsList=[];
    end

    properties(Access=public,Hidden=true)
compileParameter
    end

    properties(Access=private)
m_layers
m_deployableNWArray
m_connections
    end

    methods(Static=true)
        function fpgaLayers=getSingletonLayer(params,layerType)
            fpgaLayers=[];
            for i=1:length(params)
                if(isequal((params{i}.type),layerType))
                    assert(isempty(fpgaLayers),'Too many %s Layers',layerType);
                    fpgaLayers=params{i}.params;
                end
            end
        end
    end

    methods(Access=public,Hidden=true)

        function obj=deployableNetwork(layers)

            obj.m_layers=layers;

            obj.m_deployableNWArray=[];
            obj.m_connections=[];
        end

        function setDAGNetInfo(this,deployableNWArray,connections)
            this.m_deployableNWArray=deployableNWArray;
            this.m_connections=connections;
        end

        function setDDROffsetTable(obj,table)

            obj.DDROffsetTable=table;
        end

        function setOutputComponentsList(obj,outputComponentsList)
            obj.outputComponentsList=outputComponentsList;
        end

        function setInputFrameNumberLimit(obj,inputFrameNumberLimit)
            obj.InputFrameNumberLimit=inputFrameNumberLimit;
        end

        function setCnnProcessor(obj,cnnProcessor)
            obj.CnnProcessor=cnnProcessor;
        end

    end

    methods(Access=public)
        function layers=getLayers(this)
            layers=this.m_layers;
        end

        function output=predict(this,inputImage)



            if(isempty(this.m_deployableNWArray)&&isempty(this.m_connections))

                validateInput(this,inputImage);

                if all(cellfun(@(x)isa(x,'single'),inputImage))
                    temp=inputImage;
                else
                    temp=cellfun(@(x)single(x),inputImage,'UniformOutput',false);
                end

                if(isempty(this.CnnProcessor))


                    for i=1:numel(this.m_layers)
                        imageData=this.m_layers{i}.forward(inputImage{1});
                    end
                    output=imageData;
                    return;
                end

                processorInfo=this.CnnProcessor.getBCC;
                convDataType=processorInfo.convp.kernelDataType;

                if numel(inputImage)==1
                    data=temp{1};
                    for i=1:numel(this.m_layers)
                        m_layer=this.m_layers{i};
                        if isa(m_layer,'dnnfpga.deployablenetwork.fpgaLayer')
                            fpgaLayerIndex=i;
                            break;
                        end
                        data=m_layer.forward(data);
                    end
                    temp{1}=data;
                    temp=this.m_layers{fpgaLayerIndex}.forward(temp);
                else

                    for i=1:numel(this.m_layers)
                        m_layer=this.m_layers{i};
                        if isa(m_layer,'dnnfpga.deployablenetwork.fpgaLayer')
                            fpgaLayerIndex=i;
                            break;
                        end
                    end


                    for inputIndex=1:numel(inputImage)




                        imageData=temp{inputIndex};
                        if(strcmpi(convDataType,'single'))
                            for i=[inputIndex,inputIndex+numel(inputImage)]
                                imageData=this.m_layers{i}.forward(imageData);
                            end
                        else

                            for i=[inputIndex,inputIndex+numel(inputImage),inputIndex+2*numel(inputImage)]
                                imageData=this.m_layers{i}.forward(imageData);
                            end
                        end
                        temp{inputIndex}=imageData;
                    end

                    temp=this.m_layers{fpgaLayerIndex}.forward(temp);

                end


                if(numel(this.m_layers)>=2*numel(inputImage))
                    if(strcmpi(convDataType,'single'))








                        outputResults=cell(numel(this.outputComponentsList),1);

                        for outputIndex=1:numel(this.outputComponentsList)
                            varargin={temp{outputIndex,1},temp{outputIndex,2}};

                            outputResults{outputIndex}=this.m_layers{fpgaLayerIndex+1+((outputIndex-1)*2)}.forward(varargin);

                            outputResults{outputIndex}=this.m_layers{fpgaLayerIndex+(outputIndex*2)}.forward(outputResults{outputIndex});
























                            outputResults{outputIndex}=this.forwardFunctionForMultipleOutputs(this.outputComponentsList{outputIndex}.name,this.m_layers,varargin);
                        end
                    else








                        outputResults=cell(numel(this.outputComponentsList),1);

                        for outputIndex=1:numel(this.outputComponentsList)
                            outputResults{outputIndex}=temp{outputIndex,1};
                            isOutputFromConv=temp{outputIndex,2};
                            varargin=[];
                            varargin{1}=outputResults{outputIndex};
                            varargin{2}=isOutputFromConv;
                            outputResults{outputIndex}=this.forwardFunctionForMultipleOutputs(this.outputComponentsList{outputIndex}.name,this.m_layers,varargin);
                        end
                    end
                    output=outputResults;
                end
            else




                validateInputCNN5(this,inputImage);

                if(numel(size(inputImage))==4)

                    numImages=size(inputImage,4);
                else
                    numImages=1;
                end

                output=[];
                for frameNum=1:numImages

                    input=inputImage(:,:,:,frameNum);
                    result=[];
                    temp=[];
                    multiInput=[];

                    if isa(input,'single')
                        temp=input;
                    else
                        temp=single(input);
                    end


                    layers=this.m_deployableNWArray(1).getLayers;


                    for j=1:numel(layers)
                        temp=layers{j}.forward(temp);
                    end
                    input=temp;
                    result{1}=input;

                    for i=2:numel(this.m_deployableNWArray)
                        if(numel(this.m_connections{i})==1)

                            layers=this.m_deployableNWArray(i).getLayers;



                            temp=result{this.m_connections{i}};
                            temp=temp(1:prod([layers{1}.m_params.inputSize]));



                            temp=reshape(temp,[layers{1}.m_params.inputSize]);
                            for j=1:numel(layers)
                                temp=layers{j}.forward(temp);
                            end
                            result{i}=temp;
                        else
                            layers=this.m_deployableNWArray(i).getLayers;



                            for k=1:numel(this.m_connections{i})
                                tempResult=result{this.m_connections{i}(k)};





                                if(~iscell(layers{1}.m_params.inputSize))
                                    tempResult=tempResult(1:prod([layers{1}.m_params.inputSize]));
                                    tempResult=reshape(tempResult,[layers{1}.m_params.inputSize]);
                                end
                                multiInput{k}=tempResult;
                            end

                            temp=multiInput;
                            for j=1:numel(layers)
                                temp=layers{j}.forward(temp);
                            end
                            result{i}=temp;
                        end
                    end

                    resultSize=size(result{end});

                    if(resultSize(1)==1&&resultSize(2)==1)



                        result{end}=reshape(result{end},[1,prod(resultSize)]);
                        output=[output;result{end}];
                    elseif((isfield(this.m_deployableNWArray(end).getLayers{end-1}.m_params,'outputSize'))&&(this.m_deployableNWArray(end).getLayers{end-1}.m_params.outputSize(end)==1)...
                        ||(isfield(this.m_deployableNWArray(end).getLayers{end-1}.m_params,'inputSize'))&&(this.m_deployableNWArray(end).getLayers{end-1}.m_params.inputSize(end)==1))



                        output=cat(numel(resultSize)+2,output,result{end});
                    else


                        output=cat(numel(resultSize)+1,output,result{end});
                    end
                end
            end
        end

        function output=activations(this,image,layerName,varargin)

            output=[];
            if(isempty(this.m_deployableNWArray)&&isempty(this.m_connections))






                if(~iscell(image))
                    inputImage{1}=image;
                else
                    inputImage=image;
                end
                validateInput(this,inputImage);


                if all(cellfun(@(x)isa(x,'single'),inputImage))
                    temp=inputImage;
                else
                    temp=cellfun(@(x)single(x),inputImage,'UniformOutput',false);
                end


                p=inputParser;



                addParameter(p,'FixedPointOutput',false);
                parse(p,varargin{:});










                FixedPointOutput=p.Results.FixedPointOutput;


                processorInfo=this.CnnProcessor.getBCC;
                convDataType=processorInfo.convp.kernelDataType;
                fcDataType=processorInfo.fcp.kernelDataType;
                flag=strcmp(convDataType,'int8')&&strcmp(fcDataType,'int8');
                if~strcmp(convDataType,fcDataType)
                    error(message('dnnfpga:quantization:UnsupportedDataTypeCombinationAllMustSame'));
                end

                activationsObtained=false;

                for inputIndex=1:numel(inputImage)




                    imageData=temp{inputIndex};
                    if(strcmpi(convDataType,'single'))
                        for i=[inputIndex,inputIndex+numel(inputImage)]
                            imageData=this.m_layers{i}.forward(imageData);
                            if(strcmp(this.m_layers{i}.m_layerName,layerName))
                                output=single(imageData);
                                activationsObtained=true;
                                break;
                            end
                            temp{inputIndex}=imageData;
                        end
                    else




                        for i=[inputIndex,inputIndex+numel(inputImage),inputIndex+2*numel(inputImage)]
                            imageData=this.m_layers{i}.forward(imageData);
                            if(strcmp(this.m_layers{i}.m_layerName,layerName))
                                if(strcmp(this.m_layers{i}.m_layerName,'QuantizeInput')||...
                                    strcmp(this.m_layers{i}.m_layerName,'InputToFPGA'))
                                    output=imageData;
                                else
                                    output=single(imageData);
                                end
                                activationsObtained=true;
                                break;
                            end
                        end
                    end
                end
                if(~activationsObtained)
                    for i=2*inputIndex:length(this.m_layers)

                        if(strcmp(this.m_layers{i}.m_layerName,layerName))










                            while((i<=length(this.m_layers))&&(strcmp(this.m_layers{i}.m_layerName,layerName)||(strcmp(this.m_layers{i}.m_layerName,'InputToFPGA')&&flag)))
                                temp=this.m_layers{i}.forward(temp);
                                i=i+1;


                                if(strcmp(convDataType,'int8')&&~FixedPointOutput)
                                    temp=this.m_layers{i}.forward(temp);
                                end
                                break;
                            end
                            break;
                        end
                        temp=this.m_layers{i}.forward(temp);
                    end

                    output=[output;single(temp)];
                end
            else


                p=inputParser;


                addParameter(p,'FixedPointOutput',false);
                parse(p,varargin{:});
                FixedPointOutput=p.Results.FixedPointOutput;


                validateInputCNN5(this,image);

                layerName=validateActivationLayer(this,layerName);

                if(numel(size(image))==4)

                    numImages=size(image,4);
                else
                    numImages=1;
                end

                for frameNum=1:numImages
                    input=image(:,:,:,frameNum);
                    result=[];
                    temp=[];
                    multiInput=[];

                    if isa(input,'single')
                        temp=input;
                    else
                        temp=single(input);
                    end







                    if strcmp(layerName,this.m_deployableNWArray(end).getLayers{end}.m_layerName)
                        resultVal=this.predict(input);
                        output=cat(numel(size(resultVal))+1,output,resultVal);
                        if(frameNum==numImages)
                            output=reshapeOutput(this,output);
                            return;
                        else
                            continue;
                        end
                    end


                    layers=this.m_deployableNWArray(1).getLayers;
                    for j=1:numel(layers)
                        temp=layers{j}.forward(temp);


                        if strcmp(layerName,layers{1}.m_layerName)
                            output=cat(numel(size(temp))+1,output,single(temp));
                            if(frameNum==numImages)
                                output=reshapeOutput(this,output);
                                return;
                            else

                                break;
                            end
                        end
                    end
                    if strcmp(layerName,layers{1}.m_layerName)


                        continue;
                    end
                    result{1}=temp;


                    processorInfo=this.CnnProcessor.getBCC;
                    convDataType=processorInfo.convp.kernelDataType;
                    fcDataType=processorInfo.fcp.kernelDataType;
                    adderDataType=processorInfo.addp.kernelDataType;

                    if~(strcmp(convDataType,fcDataType)&&strcmp(convDataType,adderDataType))
                        error(message('dnnfpga:quantization:UnsupportedDataTypeCombinationDAGNet'));
                    end

                    for i=2:length(this.m_deployableNWArray)
                        if(numel(this.m_connections{i})==1)
                            temp=result{this.m_connections{i}};
                            temp=temp(1:prod([this.m_deployableNWArray(i).getLayers{1}.m_params.inputSize]));



                            temp=reshape(temp,[this.m_deployableNWArray(i).getLayers{1}.m_params.inputSize]);

                            [temp,breakOut,j]=findActivationsLayer(this,layerName,i,temp,convDataType,FixedPointOutput);
                            result{i}=temp;
                        else


                            for k=1:numel(this.m_connections{i})
                                multiInput{k}=result{this.m_connections{i}(k)};





                                if(~iscell(this.m_deployableNWArray(i).getLayers{1}.m_params.inputSize))
                                    multiInput{k}=multiInput{k}(1:prod([this.m_deployableNWArray(i).getLayers{1}.m_params.inputSize]));
                                    multiInput{k}=reshape(multiInput{k},[this.m_deployableNWArray(i).getLayers{1}.m_params.inputSize]);
                                end
                            end
                            temp=multiInput;
                            [temp,breakOut,j]=findActivationsLayer(this,layerName,i,temp,convDataType,FixedPointOutput);
                            result{i}=temp;
                        end
                        if breakOut
                            break;
                        end
                    end
                    if(~isempty(this.m_deployableNWArray)&&~isempty(this.m_connections))
                        if isfield(this.m_deployableNWArray(i).getLayers{j}.m_params,'outputSize')
                            temp=temp(1:prod([this.m_deployableNWArray(i).getLayers{j}.m_params.outputSize]));
                            temp=reshape(temp,[this.m_deployableNWArray(i).getLayers{j}.m_params.outputSize]);
                            output=cat(numel(size(temp))+1,output,single(temp));
                            if(frameNum==numImages)
                                output=reshapeOutput(this,output);
                                return;
                            else
                                continue;
                            end
                        end
                        if i<length(this.m_deployableNWArray)&&isfield(this.m_deployableNWArray(i+1).getLayers{1}.m_params,'inputSize')
                            temp=temp(1:prod([this.m_deployableNWArray(i+1).getLayers{1}.m_params.inputSize]));
                            temp=reshape(temp,[this.m_deployableNWArray(i+1).getLayers{1}.m_params.inputSize]);
                            output=cat(numel(size(temp))+1,output,single(temp));
                            if(frameNum==numImages)
                                output=reshapeOutput(this,output);
                                return;
                            else
                                continue;
                            end
                        end
                    end



                    output=cat(numel(size(temp))+1,output,single(temp));
                    if(frameNum==numImages)
                        output=reshapeOutput(this,output);
                    end
                end
            end

        end

        function result=forwardFunctionForMultipleOutputs(this,outputName,deployableNWLayers,varargin)
            indexesToExecute=[];
            j=1;









            for i=numel(deployableNWLayers):-1:1
                if(strcmpi(outputName,deployableNWLayers{i}.m_layerName))
                    outLayerIndex=i;
                    indexesToExecute(j)=outLayerIndex;
                    j=j+1;
                    outLayerIndex=outLayerIndex-1;
                    while(~strcmpi(deployableNWLayers{outLayerIndex}.m_layerName,'OutputFromFPGA'))
                        indexesToExecute(j)=outLayerIndex;
                        j=j+1;
                        outLayerIndex=outLayerIndex-1;
                    end
                    indexesToExecute(j)=outLayerIndex;
                    break;
                end
            end


















            tempResult=deployableNWLayers{indexesToExecute(end)}.forward(varargin{:});
            for i=numel(indexesToExecute)-1:-1:1
                tempResult=deployableNWLayers{indexesToExecute(i)}.forward(tempResult);
            end
            result=tempResult;
        end

        function fpgaLayers=getSingletonFPGALayer(this)
            allLayers=this.getLayers();

            fpgaLayers=[];
            for i=1:length(allLayers)
                if isequal(class(allLayers{i}),'dnnfpga.deployablenetwork.fpgaLayer')
                    assert(isempty(fpgaLayers),'Too many FPGA Layers');
                    fpgaLayers=allLayers{i};
                end
            end
        end




        function init(this,verbose)
            for i=1:length(this.m_layers)
                this.m_layers{i}.init(verbose);
            end
        end
    end


    methods(Access=protected)

        function expected=getExpectedInputSize(this,i)
            expected=this.m_layers{i}.getInputSize();
        end



        function validateInput(this,input)

            for i=1:numel(input)
                expectedSize=this.getExpectedInputSize(i);
                if isempty(expectedSize)
                    return;
                end
                expectedSize(expectedSize==1)=[];
                if(length(expectedSize)==2)
                    inputSize=size(input{i});
                    if(length(inputSize)==3)
                        if(~any(inputSize==1))





                            error(message('dnnfpga:workflow:InvalidDataWrongSize',mat2str(expectedSize),mat2str(size(input{i}))));
                        end
                    end
                end
                sz=size(input{i});
                sz(sz==1)=[];
                if length(sz)==(length(expectedSize)+1)
                    sz(end)=[];
                end
                if length(sz)~=length(expectedSize)||~all(sz==expectedSize)
                    error(message('dnnfpga:workflow:InvalidDataWrongSize',mat2str(expectedSize),mat2str(sz)));
                end
            end

        end

        function validateInputCNN5(this,input)
            if~isnumeric(input)
                error(message('dnnfpga:workflow:InvalidDataNotNumeric',class(input)));
            end
            if(numel(size(input))>4)
                error(message('dnnfpga:workflow:InvalidDataMultiFrame',numel(size(input))));
            end
            if(~isempty(this.m_deployableNWArray))
                layers=this.m_deployableNWArray(1).getLayers;
                expectedSize=layers{1}.getInputSize();

                if isempty(expectedSize)
                    return;
                end
                expectedSize(expectedSize==1)=[];
                if(length(expectedSize)==2)
                    inputSize=size(input);
                    if(length(inputSize)==3)
                        if(~any(inputSize==1))





                            error(message('dnnfpga:workflow:InvalidDataWrongSize',mat2str(expectedSize),mat2str(size(input))));
                        end
                    end
                end
                sz=size(input);
                sz(sz==1)=[];
                if length(sz)==(length(expectedSize)+1)
                    sz(end)=[];
                end
                if length(sz)~=length(expectedSize)||~all(sz==expectedSize)
                    error(message('dnnfpga:workflow:InvalidDataWrongSize',mat2str(expectedSize),mat2str(size(input))));
                end
            end
        end

        function layerName=validateActivationLayer(this,layerName)




            if~ischar(layerName)&&~isstring(layerName)
                error(message('dnnfpga:workflow:InvalidInputWrongClass','LayerName','Charachter or String',class(layerName)));
            end

            validLayer=false;
            for i=1:numel(this.m_deployableNWArray)
                layers=this.m_deployableNWArray(i).getLayers;
                for j=1:numel(layers)





                    if isfield(layers{j}.m_params,'frontendLayers')&&numel(layers{j}.m_params.frontendLayers)>1
                        if strcmp(layers{j}.m_params.frontendLayers{1},layerName)
                            warning(message('dnnfpga:dnnfpgacompiler:UnsupportedActivationLayer',...
                            layers{j}.m_params.frontendLayers{end}));
                            validLayer=true;
                            break;
                        end
                        if strcmp(layers{j}.m_params.frontendLayers{end},layerName)
                            layerName=layers{j}.m_params.frontendLayers{1};
                            validLayer=true;
                            break;
                        end
                    end
                    getLayers=strsplit(layers{j}.m_layerName,'>>');
                    if(numel(getLayers)==2)





                        if strcmp(getLayers{1},layerName)
                            warning(message('dnnfpga:dnnfpgacompiler:UnsupportedActivationLayer',getLayers{2}));
                            layerName=layers{j}.m_layerName;
                            validLayer=true;
                            break;
                        end
                        if strcmp(getLayers{2},layerName)
                            layerName=layers{j}.m_layerName;
                            validLayer=true;
                            break;
                        end
                    else
                        if strcmp(getLayers,layerName)
                            validLayer=true;
                            break;
                        end
                    end

                end
                if validLayer
                    break;
                end
            end


            if~validLayer
                error(message('dnnfpga:dnnfpgacompiler:InvalidActivationLayer',layerName));
            end
        end

        function[temp,breakOut,j]=findActivationsLayer(this,layerName,i,temp,convDataType,FixedPointOutput)


            breakOut=false;
            layers=this.m_deployableNWArray(i).getLayers;
            for j=1:length(layers)

                if(strcmp(layers{j}.m_layerName,layerName))


                    while((j<=length(layers))&&(strcmp(layers{j}.m_layerName,layerName)))
                        temp=layers{j}.forward(temp);


                        if(strcmp(convDataType,'single')||FixedPointOutput||...
                            (isfield(layers{j}.m_params,'layerType')&&(strcmp(layers{j}.m_params.layerType,'FPGA_Lrn2D')||strcmp(layers{j}.m_params.layerType,'nnet.cnn.layer.SoftmaxLayer'))))
                            breakOut=true;
                            break;
                        end


                        if(~FixedPointOutput&&~isa(temp,'single')&&strcmp(convDataType,'int8'))
                            parameter.input=temp;









                            if(isfield(layers{j}.m_params,'outputExp'))

                                parameter.params{1}.rescaleExp=layers{j}.m_params.rescaleExp-layers{j}.m_params.outputExp;
                                parameter.outputExp=layers{j}.m_params.outputExp;
                                if numel(parameter.params{1}.rescaleExp)==1


                                    temp=dnnfpga.processorbase.processorUtils.int32Toint8Conversion(parameter,parameter.input);
                                    temp=dnnfpga.processorbase.processorUtils.int8ToSingleConversion(parameter,temp,parameter.outputExp);
                                else

                                    int32Temp=dnnfpga.processorbase.processorUtils.int32Toint8Conversion(parameter,parameter.input);
                                    temp=single([]);
                                    for k=1:numel(parameter.params{1}.rescaleExp)
                                        temp(:,:,k)=dnnfpga.processorbase.processorUtils.int8ToSingleConversion(parameter,int32Temp(:,:,k),parameter.outputExp);
                                    end
                                end
                            else

                                parameter.params{1}.rescaleExp=layers{j}.m_params.rescaleExp;
                                temp=dnnfpga.processorbase.processorUtils.int8ToSingleConversion(parameter,parameter.input,parameter.params{1}.rescaleExp);
                            end
                            breakOut=true;
                            break;
                        end
                        j=j+1;
                    end
                    break;
                end
                temp=layers{j}.forward(temp);
            end
        end


        function output=reshapeOutput(this,output)

            outputSize=size(output);
            if(~all(outputSize==1))
                outputSize(outputSize==1)=[];
            end
            if(numel(outputSize)==1)

                output=reshape(output,[1,outputSize]);
            else
                output=reshape(output,outputSize);
            end
        end
    end
end


