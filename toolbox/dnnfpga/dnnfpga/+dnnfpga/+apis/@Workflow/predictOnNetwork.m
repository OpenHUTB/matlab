function results=predictOnNetwork(this,imgs,streamingMode,streamingContinuous,...
    useCustomBaseAddr,inputBaseAddr,outputBaseAddr,resetBefore,resetAfter,...
    verbose)




    isRNN=dnnfpga.dagCompile.Utils.isRNN(this.Network);

    if isRNN
        imagesRNN=cell(1,numel(imgs));
        for i=1:numel(imgs)
            img=imgs{i};
            sz=size(img);
            seqLength=sz(2);
            image=[];
            for j=1:seqLength
                oneImage=reshape(img(:,j),1,1,[]);
                image=cat(4,image,oneImage);
            end
            imagesRNN{i}=image;
        end
        imgs=imagesRNN;
    end

    dn=this.DeployableNet;
    if(ischar(dn))
        dn=load(dn);
        dn=dn.deployableNW;
    end


    for i=1:numel(imgs)

        if~streamingMode&&dn.InputFrameNumberLimit<size(imgs{i},4)
            msg=message('dnnfpga:dnnfpgacompiler:InputFrameNumberExceedLimit',...
            size(imgs{i},4),dn.InputFrameNumberLimit);
            error(msg);
        end
    end

    if streamingMode&&dn.InputFrameNumberLimit<2
        msg=message('dnnfpga:dnnfpgacompiler:InputFrameNumberLimitTooSmall',...
        dn.InputFrameNumberLimit);
        error(msg);
    end

    hPlatform=this.constructProcessorPlatform();
    hPlatform.Verbose=verbose;
    fd=dnnfpga.bitstreambase.fpgaDeployment(dn,hPlatform,...
    streamingMode,streamingContinuous,...
    useCustomBaseAddr,inputBaseAddr,outputBaseAddr);


    results=fd.predict(imgs,resetBefore,resetAfter);


    if dnnfpga.dagCompile.Utils.isRNN(this.Network)

        results=results{1};
        results=squeeze(results);
        results={results};
    end

































    fpgaLayer=this.DeployableNet.getSingletonFPGALayer;
    if~isempty(fpgaLayer)
        if isa(this.hProcessorPlatform,'dnnfpga.bitstreambase.cnn5ProcessorPlatform')

            import dnnfpga.dagCompile.DataFormat %#ok<SIMPT> 






            hasGAPinConvLayer=dnnfpga.bitstreambase.checkDeployableIRDAG(fpgaLayer);


            outputComponents=fpgaLayer.getDepolyableIR.getOutputComponents();
            for i=1:numel(outputComponents)
                outputDataFormat=outputComponents{i}.inputs.net.dataFormat;
                isOutputFromFC=isSameDataFormat(outputDataFormat,DataFormat.FC);
                isOutputFromGAP=hasGAPinConvLayer&&all(size(results{i},1:2)==1);

                isDAGNetwork=isa(this.Network,'DAGNetwork');
                isDLNetwork=isa(this.Network,'dlnetwork');
                isPredictCall=isempty(fpgaLayer.getActivationLayer());

                if(isOutputFromFC||isOutputFromGAP)&&isDAGNetwork&&isPredictCall&&~isRNN



                    if numel(size(results{i}))>2
                        results{i}=squeeze(results{i})';
                    end
                elseif(isOutputFromFC)&&isDLNetwork&&~isRNN





                    if numel(size(results{i}))>2





                        ldc=sum(size(results{i},1:2)==1);

                        n=ndims(results{i});
                        permuteOrder=mod((1:n)-1+ldc,n)+1;
                        results{i}=permute(results{i},permuteOrder);
                    end
                end
            end
        end
    end


