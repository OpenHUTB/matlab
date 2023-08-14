classdef ElementwiseAffineCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.elementwise_affine_layer_comp';


        compKind='elementwiseaffinelayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.compKind;
        end

        function validate(layer,validator)

            if isa(layer,'rl.layer.ScalingLayer')
                bias=layer.Bias;
            else
                bias=layer.Offset;
            end

            layerInfo=validator.getLayerInfo(layer.Name);


            if~dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.isValidScaleOrOffset(layer.Scale,...
                layerInfo.inputSizes,layerInfo.inputFormats)||...
                ~dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.isValidScaleOrOffset(bias,...
                layerInfo.inputSizes,layerInfo.inputFormats)
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_eltaff_param',layer.Name);
                validator.handleError(layer,errorMessage);
            end
        end

        function comp=convert(layer,converter,comp)

            if isa(layer,'rl.layer.ScalingLayer')
                bias=layer.Bias;
            else
                bias=layer.Offset;
            end

            comp.setScaleHeight(size(layer.Scale,1));
            comp.setScaleWidth(size(layer.Scale,2));
            comp.setScaleChannels(size(layer.Scale,3));
            comp.setOffsetHeight(size(bias,1));
            comp.setOffsetWidth(size(bias,2));
            comp.setOffsetChannels(size(bias,3));
            comp.setIsClippedAffine(logical(0));%#ok
            comp.setLowerBound(-1);
            comp.setUpperBound(-1);

            fileNames=converter.getParameterFileNames(layer.Name);
            scaleFile=fileNames{1};
            offsetFile=fileNames{2};

            comp.setScaleFile(scaleFile);
            comp.setOffsetFile(offsetFile);

        end

        function saveFiles(layer,fileSaver)

            scaleFileNamePostfix='_scale.bin';
            offsetFileNamePostfix='_offset.bin';
            scaleFileName=strcat(fileSaver.getFilePrefix,layer.Name,scaleFileNamePostfix);
            offsetFileName=strcat(fileSaver.getFilePrefix,layer.Name,offsetFileNamePostfix);

            scaleFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            scaleFileName,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            offsetFile=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
            offsetFileName,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);

            fileSaver.setParameterFileNamesMap(layer.Name,{scaleFile,offsetFile});

            if isa(layer,'rl.layer.ScalingLayer')
                bias=layer.Bias;
            else
                bias=layer.Offset;
            end


            scaleT=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.reshapeAndTransposeScaleBias(layer.Scale);
            offsetT=dltargets.internal.compbuilder.ElementwiseAffineCompBuilder.reshapeAndTransposeScaleBias(bias);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,scaleFile,scaleT);

            dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
            fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,fileSaver.Precision,offsetFile,offsetT);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'ScaleSize',size(layer.Scale));
            if isa(layer,'rl.layer.ScalingLayer')
                aStruct.BiasSize=size(layer.Bias);
            else
                aStruct.OffsetSize=size(layer.Offset);
            end
        end

    end

    methods(Static,Access=private)

        function scaleOrOffset=reshapeAndTransposeScaleBias(scaleOrOffset)


            if isvector(scaleOrOffset)
                scaleOrOffset=reshape(scaleOrOffset,[1,1,size(scaleOrOffset,1)]);
            end

            scaleOrOffset=dltargets.internal.permuteHyperParameters(scaleOrOffset);
        end

        function isValid=isValidScaleOrOffset(scaleOrOffset,layerInputSizes,layerInputFormats)












            scaleOrOffsetSize=[size(scaleOrOffset,1),size(scaleOrOffset,2),size(scaleOrOffset,3)];


            assert(numel(layerInputSizes)==1);
            inputSize=layerInputSizes{1};


            if any(strcmp(layerInputFormats,["CB","CBT"]))
                inputSize=[1,1,inputSize];
                if isvector(scaleOrOffset)
                    scaleOrOffsetSize=[1,1,size(scaleOrOffset,1)];
                end
            else
                assert(numel(inputSize)==4);


                assert(any(strcmp(layerInputFormats,["SSCB","SSCBT"])));
            end

            inputHeight=inputSize(1);
            inputWidth=inputSize(2);
            inputChannels=inputSize(3);

            if numel(size(scaleOrOffset))>3


                isValid=false;
            elseif isscalar(scaleOrOffset)||...
                isequal(scaleOrOffsetSize,[1,1,inputChannels])||...
                isequal(scaleOrOffsetSize,[inputHeight,inputWidth,1])||...
                isequal(scaleOrOffsetSize,[inputHeight,inputWidth,inputChannels])

                isValid=true;
            else
                isValid=false;
            end
        end
    end
end
