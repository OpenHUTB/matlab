classdef Resize2DLayer<nnet.layer.Layer





%#codegen  


    properties
Scale
OutputSize
EnableReferenceInput
Method
GeometricTransformMode
NearestRoundingMode
    end

    properties(SetAccess=private,Hidden)



        DlresizeMethodName=''
        GetOutputSizeAndScale=''
    end

    methods
        function layer=Resize2DLayer(name,scale,outputSize,enableReferenceInput,method,geometricTransformMode,nearestRoundingMode)
            coder.allowpcode('plain');
            layer.Name=name;
            layer.Scale=scale;
            layer.OutputSize=outputSize;
            layer.EnableReferenceInput=enableReferenceInput;
            layer.Method=method;
            layer.GeometricTransformMode=geometricTransformMode;
            layer.NearestRoundingMode=nearestRoundingMode;
            layer.Type='Resize';
        end

        function Zfin=predict(layer,varargin)



            numSpatialDims=2;

            if layer.NumInputs==2
                XInit=varargin{1};
                referenceSize=size(varargin{2},1:numSpatialDims);



                voidT=coder.opaque("void");
                varargin2=varargin{2};
                coder.ceval("#__dnn_dummy_fcn",coder.rref(varargin2,"like",voidT));
            else
                XInit=varargin{1};
                referenceSize=[];
            end

            inputIsDlarray=isdlarray(XInit);
            if coder.const(inputIsDlarray)
                X=extractdata(XInit);
                labels=dims(XInit);
            else
                X=XInit;
                labels='';
            end

            coder.internal.errorIf(ndims(X)>4,'images:resizeLayer:invalidInput2D')

            inputSpatialDimSize=size(X,1:numSpatialDims);



            [outputSize,scale]=coder.const(@iGetOutputSizeAndScale,layer.Scale,layer.OutputSize,layer.EnableReferenceInput,numSpatialDims,inputSpatialDimSize,referenceSize);



            [start,stride,stop]=coder.const(@getInputQueryLocations,layer.GeometricTransformMode,outputSize,scale);


            Z=interpSpatialDims(X,start,stop,stride,layer.Method,layer.NearestRoundingMode,scale,inputSpatialDimSize);

            if coder.const(inputIsDlarray)
                Zfin=dlarray(Z,labels);
            else
                Zfin=Z;
            end
        end
    end
    methods(Static=true)
        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.Resize2DLayer(mlObj.Name,mlObj.Scale,mlObj.OutputSize,mlObj.EnableReferenceInput,mlObj.Method,mlObj.GeometricTransformMode,mlObj.NearestRoundingMode);
            cgObj.NumInputs=mlObj.NumInputs;
            cgObj.InputNames=mlObj.InputNames;
        end
    end

    methods(Static=true)
        function mlObj=matlabCodegenFromRedirected(cgObj)
            mlObj=nnet.cnn.layer.Resize2DLayer(cgObj.Name,cgObj.Scale,cgObj.OutputSize,cgObj.EnableReferenceInput,cgObj.Method,cgObj.GeometricTransformMode,cgObj.NearestRoundingMode);
        end
    end
end

function[newOutputSize,newScale]=iGetOutputSizeAndScale(scale,outputSize,enableReferenceInput,numSpatialDims,inputSpatialDimSize,referenceSize)
    scaleSpecified=~isempty(scale);
    outputSizeSpecified=~isempty(outputSize);
    if scaleSpecified
        if isscalar(scale)
            newScale=repmat(scale,1,numSpatialDims);
        else
            newScale=scale;
        end
        newOutputSize=scale.*inputSpatialDimSize;
    elseif outputSizeSpecified

        nanLoc=isnan(outputSize);
        nanCount=sum(nanLoc);
        validNaNSyntax=nanCount==(numSpatialDims-1);
        if validNaNSyntax
            homogeneousScale=outputSize./inputSpatialDimSize;
            homogeneousScale=homogeneousScale(~isnan(homogeneousScale));
            newOutputSize=homogeneousScale.*inputSpatialDimSize;
            newScale=repmat(homogeneousScale,1,numel(inputSpatialDimSize));
        else
            newScale=outputSize./inputSpatialDimSize;
            newOutputSize=outputSize;
        end
    elseif enableReferenceInput
        newScale=referenceSize./inputSpatialDimSize;
        newOutputSize=referenceSize;
    end
    newOutputSize=floor(newOutputSize);
end

function[start,stride,stop]=getInputQueryLocations(geometricTransformMode,outputSize,scale)
    if strcmpi(geometricTransformMode,"half-pixel")
        x=cat(1,ones(1,length(outputSize)),outputSize)';
        u=x./repmat(scale',1,2)+0.5*(1-1./repmat(scale',1,2));
        start=u(:,1);
        stop=u(:,2);
        stride=1./scale(:);

    else

        start=zeros(length(outputSize),1);
        start=start./scale(:)+1;
        stride=1./scale(:);
        stop=start+(outputSize-1)'.*stride;

    end
end

function outDim2=interpSpatialDims(X,start,stop,stride,method,nearestRoundingMode,scale,inputSpatialDimSize)

    outDim1=interpAlongSpatialDim(X,coder.const(1),start,stride,stop,method,nearestRoundingMode,scale,inputSpatialDimSize(1));
    outDim2=interpAlongSpatialDim(outDim1,coder.const(2),start,stride,stop,method,nearestRoundingMode,scale,inputSpatialDimSize(2));
end

function out=interpAlongSpatialDim(inTmp,spatialDim,start,stride,stop,method,nearestRoundingMode,scale,inputDimSize)

    permuteVec=1:ndims(inTmp);
    if spatialDim~=1
        tmp=permuteVec(1);
        permuteVec(1)=permuteVec(spatialDim);
        permuteVec(spatialDim)=tmp;
    end
    in=permute(inTmp,permuteVec);


    queryPoints=start(spatialDim):stride(spatialDim):stop(spatialDim);
    queryPoints=adjustQueryPointsToManageBoundaryBehavior(queryPoints,inputDimSize);
    if(method=="nearest")
        queryPoints=updateQueryPointsToObeyNearestRoundingMode(queryPoints,nearestRoundingMode,scale(spatialDim));
    end


    out=interp1CustomImpl(1:inputDimSize,in,queryPoints');
    out=ipermute(out,permuteVec);
end

function ptsOut=adjustQueryPointsToManageBoundaryBehavior(queryPoints,inputDimSize)
    ptsOut=queryPoints;
    ptsOut(queryPoints<1)=1;
    ptsOut(queryPoints>inputDimSize)=inputDimSize;
end

function queryPoints=updateQueryPointsToObeyNearestRoundingMode(queryPoints,nearestRoundingMode,scale)
    if strcmpi(nearestRoundingMode,"onnx-10")
        isDownsample=scale<1;
        if isDownsample
            queryPoints=ceil(queryPoints);
        else
            queryPoints=fix(queryPoints);
        end

    elseif strcmpi(nearestRoundingMode,"floor")
        queryPoints=floor(queryPoints);

    else

        queryPoints=round(queryPoints);
    end
end

function out=interp1CustomImpl(x,v,xq)

    coder.gpu.kernelfun();
    origSize=size(v);
    sizeFirst=origSize(1);
    sizeRest=prod(origSize(2:end));
    vReshaped=reshape(v,sizeFirst,sizeRest);
    out=coder.nullcopy(zeros(size(xq,1),sizeRest,'like',v));
    for i=1:size(xq,1)
        for j=1:sizeRest
            idx=floor(xq(i));
            nextIdx=ceil(xq(i));
            if idx~=nextIdx
                dx=x(idx)-x(nextIdx);
                dy=vReshaped(idx,j)-vReshaped(nextIdx,j);
                slope=dy/dx;
                intercept=vReshaped(idx,j)-slope*x(idx);
                out(i,j)=slope*xq(i)+intercept;
            else
                out(i,j)=vReshaped(idx,j);
            end

        end
    end
    out=reshape(out,[size(xq,1),origSize(2:end)]);
end
