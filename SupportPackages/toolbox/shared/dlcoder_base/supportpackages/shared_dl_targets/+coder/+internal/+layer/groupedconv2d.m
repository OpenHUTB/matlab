classdef groupedconv2d<nnet.layer.Layer
















%#codegen


    properties(SetAccess=private)
Weight
Bias
stride
paddingSize
dilation
    end

    methods
        function layer=groupedconv2d(name,Weight,Bias,stride,paddingSize,dilation)
            layer.Name=name;
            layer.Weight=Weight;
            layer.Bias=Bias;
            layer.stride=stride;
            layer.paddingSize=paddingSize;
            layer.dilation=dilation;
        end

        function Z1=predict(layer,X1)
            coder.allowpcode('plain');
            coder.inline('always');


            filterSz=size(layer.Weight);
            filterHalfSz=floor(filterSz(1:2)/2);
            numInputChannelsPerGroup=filterSz(3);

            numGroups=filterSz(5);
            numObservations=size(X1,4);

            outputSz=coder.const(@iComputeOutputSize,size(X1),filterSz,...
            layer.paddingSize,layer.stride,layer.dilation);


            X1=reshape(X1,size(X1,1),size(X1,2),numInputChannelsPerGroup,numGroups,numObservations);


            Z1=coder.nullcopy(zeros(outputSz,'like',X1));

            for batch=1:size(Z1,5)
                for grpIdx=1:size(Z1,4)
                    for filterIdxInGroup=1:size(Z1,3)
                        for col=1:size(Z1,2)
                            for row=1:size(Z1,1)


                                out_pixel=layer.Bias(1,1,filterIdxInGroup,grpIdx);





                                for r=1:filterSz(1)
                                    for c=1:filterSz(2)
                                        for chPerGroup=1:numInputChannelsPerGroup
                                            input_row=(layer.stride(1)*(row-1)+1)+...
                                            layer.dilation(1)*filterHalfSz(1)+...
                                            (layer.dilation(1)*(r-1-filterHalfSz(1)))-...
                                            layer.paddingSize(1);
                                            input_col=(layer.stride(2)*(col-1)+1)+...
                                            layer.dilation(2)*filterHalfSz(2)+...
                                            (layer.dilation(2)*(c-1-filterHalfSz(2)))-...
                                            layer.paddingSize(3);


                                            if input_row>0&&input_col>0&&input_row<=size(X1,1)&&input_col<=size(X1,2)
                                                input_pixel=X1(input_row,input_col,chPerGroup,grpIdx,batch);

                                                out_pixel=out_pixel+input_pixel*layer.Weight(r,c,chPerGroup,filterIdxInGroup,grpIdx);
                                            end
                                        end
                                    end
                                end

                                Z1(row,col,filterIdxInGroup,grpIdx,batch)=out_pixel;
                            end
                        end
                    end
                end
            end

            Z1=reshape(Z1,size(Z1,1),size(Z1,2),size(Z1,3)*size(Z1,4),size(Z1,5));

        end
    end
end


function outputSz=iComputeOutputSize(inputSize,filterSz,paddingSize,strideHW,dilationHW)
    if numel(inputSize)<4
        batchSize=1;
    else
        batchSize=inputSize(4);
    end
    inputHW=int32(inputSize(1:2));
    filterHW=int32(dilationHW).*(int32(filterSz(1:2))-1)+1;
    top=1;bottom=2;left=3;right=4;
    paddingHW=[paddingSize(top)+paddingSize(bottom),paddingSize(left)+paddingSize(right)];
    outputHW=floor(single(inputHW+int32(paddingHW)-filterHW)./single(strideHW))+1;
    numFiltersPerGroup=int32(filterSz(4));
    numGroups=int32(filterSz(5));
    outputSz=[outputHW,numFiltersPerGroup,numGroups,batchSize];
end
