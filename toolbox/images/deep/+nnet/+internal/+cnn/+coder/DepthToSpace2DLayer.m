classdef DepthToSpace2DLayer<nnet.layer.Layer
%#codegen



    properties(SetAccess=private)






BlockSize






Mode

    end

    methods
        function layer=DepthToSpace2DLayer(name,blocksize,mode)
            coder.allowpcode('plain');
            layer.Name=name;
            layer.BlockSize=blocksize;
            layer.Mode=mode;
            layer.Type='Depth to space';
            layer.Description=['Depth to space with block size ',mat2str(blocksize)];
        end

        function ZFinal=predict(layer,XInit)

            coder.internal.errorIf(ndims(XInit)>4,'images:depthToSpace:invalidInput2D');
            [inputHeight,inputWidth,inputChannel,batchSize]=size(XInit);
            outputChannel=inputChannel/((layer.BlockSize(1)*layer.BlockSize(2)));
            coder.internal.errorIf(((floor(outputChannel)*(layer.BlockSize(1)*layer.BlockSize(2)))~=inputChannel),'images:depthToSpace:InputChannelDivisble');
            outputHeight=inputHeight*layer.BlockSize(1);
            outputWidth=inputWidth*layer.BlockSize(2);

            isInputDlarray=isdlarray(XInit);

            if coder.const(isInputDlarray)
                X=extractdata(XInit);
            else
                X=XInit;
            end



            Z=coder.nullcopy(zeros(outputHeight,outputWidth,outputChannel,batchSize,'like',X));




            switch(layer.Mode)

            case "dcr"

                for idxBlockSizeX=1:layer.BlockSize(1)
                    for idxBlockSizeY=1:layer.BlockSize(2)
                        idx=(idxBlockSizeX-1)*layer.BlockSize(2)+idxBlockSizeY;
                        val=outputChannel*(idx-1)+1:outputChannel*idx;
                        Z(idxBlockSizeX:layer.BlockSize(1):size(Z,1),idxBlockSizeY:layer.BlockSize(2):size(Z,2),:,:)=X(:,:,val,:);
                    end
                end

            case "crd"

                idx=1;
                for channel=1:outputChannel
                    for idxBlockSizeX=1:layer.BlockSize(1)
                        for idxBlockSizeY=1:layer.BlockSize(2)
                            Z(idxBlockSizeX:layer.BlockSize(1):size(Z,1),idxBlockSizeY:layer.BlockSize(2):size(Z,2),channel,:)=X(:,:,idx,:);
                            idx=idx+1;
                        end
                    end
                end
            end

            if coder.const(isInputDlarray)
                ZFinal=dlarray(Z);

            else
                ZFinal=Z;
            end
        end

    end

    methods(Static=true)
        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.DepthToSpace2DLayer(mlObj.Name,mlObj.BlockSize,mlObj.Mode);
        end
    end

    methods(Static=true)
        function mlObj=matlabCodegenFromRedirected(cgObj)
            mlObj=nnet.cnn.layer.DepthToSpace2DLayer(cgObj.Name,cgObj.BlockSize,cgObj.Mode);
        end
    end
end
