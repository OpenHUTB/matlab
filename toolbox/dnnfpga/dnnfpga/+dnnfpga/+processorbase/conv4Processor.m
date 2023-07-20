classdef conv4Processor<dnnfpga.processorbase.abstractProcessor



    methods(Access=public,Hidden=true)
        function obj=conv4Processor(bcc)
            obj@dnnfpga.processorbase.abstractProcessor(bcc);
        end
    end

    methods(Access=public)
        function convp=getConvProcessor(this)
            convp=dnnfpga.processorbase.conv2Processor(this.getBCC().conv);
        end

        function convp=getInputProcessor(this)
            convp=dnnfpga.processorbase.inputProcessor(this.getBCC().ip0);
        end

        function convp=getInputProcessor0(this)
            convp=dnnfpga.processorbase.inputProcessor(this.getBCC().ip0);
        end

        function convp=getInputProcessor1(this)
            convp=dnnfpga.processorbase.inputProcessor(this.getBCC().ip1);
        end

        function convp=getOutputProcessor0(this)
            convp=dnnfpga.processorbase.outputProcessor(this.getBCC().op0);
        end


        function cycles=estimateThroughput(this,params,hw)
        end

        function lcs=resolveLC(this,params)
            assert(false,'Composite processor doesn''t resolve individual layers');
            lc=[];
        end

        function nc=resolveNC(this,params)
            nc=[];
        end

        function s=resolveOutputSize(this,params)
            s=this.getConvProcessor().resolveOutputSize({params{end}});
        end

        function s=resolveOutputSizeLayer(this,param)
            assert(false,'Shall not reach here');
        end

        function s=resolveInputSize(this,params)
            s=this.getConvProcessor().resolveInputSize({params{1}});
        end

        function s=resolveInputSizeLayer(this,param)
            assert(false,'Shall not reach here');
        end

        function output=cosim(this,param,input)
            conv2ProcessorObj=this.getConvProcessor();
            output=cosim(conv2ProcessorObj,param,input);
        end

        function tileIR=createTileIR(this,param,tileInfo,imageTilePos,result)
            tileIR=param;
            tileIR.phase=sprintf('%stile(%d, %d)',param.phase,tileInfo.imageTileIdx(1),tileInfo.imageTileIdx(2));
            tileIR.imageTilePos=imageTilePos';
            tileIR.resultTilePos=result.resultTilePos';
            tileIR.finalWriteSize=result.finalWriteSize';
            tileIR.paddingMode=result.tilePaddingSize';
            tileIR.strideMode=param.strideMode';
            tileIR.stridePhase=result.tileStridePhase';
            tileIR.outImgSize=tileInfo.outImageSize;

            tileIR.ipBurstNum=(tileIR.imageTilePos(4)-tileIR.imageTilePos(3))*ceil(tileIR.inputFeatureNum/this.getCC().conv.threadNumLimit);
            tileIR.opBurstNum=(tileIR.resultTilePos(4)-tileIR.resultTilePos(3))*ceil(tileIR.outputFeatureNum/this.getCC().conv.threadNumLimit);

            tileIR.imageTileIdx=tileInfo.imageTileIdx;

            tileIR.unpoolRemainder=result.unpoolRemainder.';
            tileIR.nextTilePos=[];
        end

        function tileIRParams=getTileIR(this,param)
            convCC=this.getCC().conv;





            if(isfield(param,'inputFeatureNumToPadForSplit'))
                if(strcmpi(param.type,'FPGA_Conv2D')||strcmpi(param.type,'FPGA_ConvND'))
                    if(param.inputFeatureNumToPadForSplit~=0)
                        error(message('dnnfpga:workflow:GroupedConvConfigNotSupported',param.phase,param.inputFeatureNum,convCC.threadNumLimitSquared));
                    end
                end
            end


            if(isfield(param,'outputFeatureNumToPadForSplit'))
                if(strcmpi(param.type,'FPGA_Conv2D')&&param.convSplitMode~=0)
                    if(param.outputFeatureNumToPadForSplit~=0)
                        numFiltersPerGroup=param.outputFeatureNum/param.convSplitMode;
                        error(message('dnnfpga:workflow:GroupedConvFiltersConfigNotSupported',param.phase,numFiltersPerGroup,convCC.threadNumLimitSquared));
                    end
                end
            end






            [inputTileImageSize,outputTileImageSize,inputMemSizeLimit,inputTileW,outputTileW]=...
            dnnfpga.processorbase.maxTileSize(convCC.inputMemDepthLimit,convCC.resultMemDepthLimit,...
            convCC.threadNumLimit,param.inputFeatureNum,param.outputFeatureNum,convCC.opSize(1:2));





            if param.maxpoolType==1||param.maxpoolType==2
                inputTileW=min(inputTileW,outputTileW);
            end

            bcc=this.getBCC();
            cc=this.getCC();



            while(true)


                if strcmpi(param.type,'FPGA_Lrn2D')
                    rSize=inputTileImageSize';
                elseif strcmpi(param.type,'FPGA_TransposedConv')
                    rSize=dnnfpga.processorbase.resultSizeUnpool(param.paddingMode,...
                    param.strideMode,param.stridePhase,param.dilationMode,...
                    [inputTileImageSize(1);inputTileImageSize(2)],param.origOpSizeValue,...
                    param.origImgSize(1:2),param.unpoolRemainder);
                elseif strcmpi(param.type,'FPGA_Unpool2D')


                    rSize=dnnfpga.processorbase.resultSize(param,...
                    param.origOpSizeValue(1),[inputTileImageSize(1);inputTileImageSize(2)],...
                    param.outputSize(1:2),bcc,cc);
                else
                    rSize=dnnfpga.processorbase.resultSize(param,...
                    param.strideMode,[inputTileImageSize(1);inputTileImageSize(2)],...
                    param.origImgSize(1:2),bcc,cc);
                end
                if(rSize(1)<=outputTileImageSize(1)&&rSize(2)<=outputTileImageSize(2))
                    break;
                end
                inputTileW=inputTileW-1;
                inputTileImageSize=[inputTileW,inputTileW].*convCC.opSize(1:2)';
            end

            if strcmpi(param.type,'FPGA_Unpool2D')
                inputTileImageSize=rSize;
                rSize=dnnfpga.processorbase.resultSizeUnpool(param.paddingMode,...
                param.strideMode,param.stridePhase,param.dilationMode,...
                [inputTileImageSize(1);inputTileImageSize(2)],param.origOpSizeValue,...
                param.origImgSize(1:2),param.unpoolRemainder);
            end

            tileIRParams={};
            tileInfo.imageSize=param.origImgSize(1:2)';
            tileInfo.weightSize=param.origOpSizeValue;
            tileInfo.strideSize=[param.strideMode,param.strideMode];
            tileInfo.atomicImageSize=inputTileImageSize;
            tileInfo.imageTileNums=ceil(tileInfo.imageSize./tileInfo.atomicImageSize);



            if(isfield(this.getBCC().conv,'outputTileWidthX'))
                if(this.getBCC().conv.outputTileWidthX<rSize(2))
                    rSize(2)=this.getBCC().conv.outputTileWidthX;
                end
            end
            if(isfield(this.getBCC().conv,'outputTileWidthY'))
                if(this.getBCC().conv.outputTileWidthY<rSize(1))
                    rSize(1)=this.getBCC().conv.outputTileWidthY;
                end
            end
            tileInfo.atomicResultSize=rSize;












            if(any(rSize(1)<=(param.paddingMode(1:2)-floor(param.origOpSizeValue(1:2)/2)))||...
                any(rSize(2)<=(param.paddingMode(3:4)-floor(param.origOpSizeValue(1:2)/2))))

                msgPad=message('dnnfpga:dnnfpgacompiler:TileSizeSmallerThanPaddingSize',...
                sprintf('[%d %d]',rSize(1),rSize(2)),...
                sprintf('[%d %d %d %d]',param.paddingMode(1),param.paddingMode(2),param.paddingMode(3),param.paddingMode(4)));
                logs=msgPad.getString;
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedTileSize',param.phase,logs);
                error(msg);

            end


            outImageSize=dnnfpga.compiler.propagateConvLayerOutputSize(param);
            tileInfo.outImageSize=outImageSize(1:2);
            tileInfo.imageTileNums=ceil(tileInfo.outImageSize./rSize)';

            for imageTileX=0:tileInfo.imageTileNums(1)-1
                for imageTileY=0:tileInfo.imageTileNums(2)-1
                    tileInfo.imageTileIdx=[imageTileX,imageTileY];
                    [imageTilePos,result]=dnnfpga.processorbase.conv4Processor.resolve(tileInfo,param);
                    assert(result.resultTilePos(1)<=result.resultTilePos(2)&&result.resultTilePos(3)<=result.resultTilePos(4));

                    assert((result.finalWriteSize(1))<=rSize(1)&&(result.finalWriteSize(2))<=rSize(2));

                    imageTileSize=[(imageTilePos(2)-imageTilePos(1)+sum(result.tilePaddingSize(1:2)));...
                    (imageTilePos(4)-imageTilePos(3)+sum(result.tilePaddingSize(3:4)))];
                    assert(all(imageTileSize*param.inputFeatureNum<=inputMemSizeLimit.*convCC.opSize(1:2)));
                    if(result.resultTilePos(1)==result.resultTilePos(2)||result.resultTilePos(3)==result.resultTilePos(4))
                        continue;
                    end









                    currImagePos=[imageTilePos(2)-imageTilePos(1);imageTilePos(4)-imageTilePos(3)];
                    if any(currImagePos<=0)
                        msgPad=message('dnnfpga:dnnfpgacompiler:InputTileValidImageSmallerThanZero',...
                        sprintf('[%d %d]',currImagePos(1),currImagePos(2)));
                        logs=msgPad.getString;
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedTileSize',param.phase,logs);
                        error(msg);

                    end





                    if((strcmpi(param.type,'FPGA_Maxpool2D')||strcmpi(param.type,'FPGA_Avgpool2D'))&&prod(result.finalWriteSize)<19)
                        param.smallLayerEn=1;
                    end
                    tileIRParams{end+1}=this.createTileIR(param,tileInfo,imageTilePos,result);



                    if length(tileIRParams)~=1
                        tileIRParams{end-1}.nextTilePos=tileIRParams{end}.imageTilePos;
                    end
                end
            end


            tileIRParams{end}.nextTilePos=tileIRParams{end}.imageTilePos;

        end


        function notRunTiledLayerPos=getNotRunTiledPos(this,tileIRParams)
            notRunTiledLayerPos=[];
            for i=1:length(tileIRParams)
                resultTilePos=[tileIRParams{i}.resultTilePos];
                notRunTiledLayerPos=vertcat(notRunTiledLayerPos,resultTilePos');
            end
        end

        function[data,notRun_tiledActivationLayerPos]=getSeqLCAndOpPerLayer(this,param,verbose,tileActivation)
            tileIRParams=getTileIR(this,param);


            if(~isempty(tileActivation)&&(tileIRParams{end}.imageTileIdx(1)<tileActivation(1)||tileIRParams{end}.imageTileIdx(2)<tileActivation(2)))
                warning(message('dnnfpga:workflow:TileActivationIndexExceeds'));
                tileActivation(1)=tileIRParams{end}.imageTileIdx(1);
                tileActivation(2)=tileIRParams{end}.imageTileIdx(2);
            end


            ip1BurstNums=[];
            op0BurstNums=[];
            convData.seqOp=[];
            convData.seqLC=[];
            ip0Data.seqOp=[];
            ip0Data.seqLC=[];
            ip1Data.seqOp=[];
            ip1Data.seqLC=[];
            op0Data.seqOp=[];
            op0Data.seqLC=[];
            pos=[];
            for i=1:length(tileIRParams)
                newParam=tileIRParams{i};
                newParam.firstLayer=param.firstLayer;
                newParam.weightBaseAddrOffset=param.weightBaseAddrOffset;
                tileConvIR=dnnfpga.processorbase.conv4Processor.createConvIR(newParam);
                if(verbose==2)
                    fprintf('%s. TilePosition - [%d %d %d %d]\n',tileConvIR.phase,newParam.resultTilePos(1),newParam.resultTilePos(2),newParam.resultTilePos(3),newParam.resultTilePos(4));
                end
                d=this.getConvProcessor().getSeqLCAndOpPerLayer(tileConvIR);
                convData.seqOp=[convData.seqOp,d.seqOp];
                convData.seqLC=[convData.seqLC,d.seqLC];


                tileIP0IR=dnnfpga.processorbase.conv4Processor.createIOPIR(newParam,true,'ip0',0);
                d=this.getInputProcessor0().getSeqLCAndOpPerLayer(tileIP0IR);
                ip0BurstNums(i)=numel(d.seqLC)/this.getCC().ip0.layerConfigNumWLimit;
                ip0Data.seqLC=[ip0Data.seqLC,d.seqLC];
                tileIP1IR=dnnfpga.processorbase.conv4Processor.createIOPIR(newParam,true,'ip1',1);
                d=this.getInputProcessor0().getSeqLCAndOpPerLayer(tileIP1IR);
                ip1BurstNums(i)=0;
                ip1Data.seqLC=[ip1Data.seqLC,d.seqLC];
                tileOP0IR=dnnfpga.processorbase.conv4Processor.createIOPIR(newParam,false,'op0',1);
                d=this.getOutputProcessor0().getSeqLCAndOpPerLayer(tileOP0IR);
                op0BurstNums(i)=numel(d.seqLC)/this.getCC().op0.layerConfigNumWLimit;
                op0Data.seqLC=[op0Data.seqLC,d.seqLC];

                if(~isempty(tileActivation)&&newParam.imageTileIdx(1)==tileActivation(1)&&newParam.imageTileIdx(2)==tileActivation(2))
                    if(i<length(tileIRParams))
                        pos=this.getNotRunTiledPos({tileIRParams{i+1:end}});
                    end
                    break;
                end
            end


            data.syncIR.conv=length(tileIRParams);
            data.syncIR.ip0=ip0BurstNums;
            data.syncIR.ip1=ip1BurstNums;
            data.syncIR.op0=op0BurstNums;

            data.seqOp.conv=convData.seqOp;
            data.seqOp.ip0=ip0Data.seqOp;
            data.seqOp.ip1=ip1Data.seqOp;
            data.seqOp.op0=op0Data.seqOp;

            data.seqLC.conv=convData.seqLC;
            data.seqLC.ip0=ip0Data.seqLC;
            data.seqLC.ip1=ip1Data.seqLC;
            data.seqLC.op0=op0Data.seqLC;
            if nargout>1
                notRun_tiledActivationLayerPos=pos;
            end
        end

        function[output,notRunActivationTilePosition]=backend(this,params,verbose,tileActivation,hasFC)

            if nargin<3
                verbose=1;
            end

            if nargin<4
                tileActivation=[];
            end





            layerData=struct('seqOp',[],'seqLC',[],'syncIR',[]);


            if~iscell(params)&&(length(params)==1)
                params={params};
            end
            notRunTiledPosition=[];

            for i=1:length(params)





                param=params{i};
                param.weightBaseAddrOffset=0;

                if i==1
                    param.firstLayer=true;
                else
                    param.firstLayer=false;
                end
                if i==length(params)
                    param.lastLayer=true;



                    if nargin<5
                        hasFC=true;
                    end
                    param.hasFC=hasFC;
                else
                    param.lastLayer=false;
                end





                if(i==length(params))
                    [layerData(i),notRunTiledPosition]=this.getSeqLCAndOpPerLayer(param,verbose,tileActivation);
                else
                    layerData(i)=this.getSeqLCAndOpPerLayer(param,verbose,[]);
                end

            end

            output.seqOp=this.flattenLayerData(layerData,'seqOp');
            output.seqLC=this.flattenLayerData(layerData,'seqLC');
            output.NC=this.resolveNC(params);

            output.syncSeqLC=this.getSyncSeqLC([layerData.syncIR],params);
            if nargout>1
                notRunActivationTilePosition=notRunTiledPosition;
            end

        end

        function kind=getKind(this)
            kind='conv';
        end

    end

    methods(Access=public,Static=true)



        function seqImg=getSeqImage(input,threadNumLimit,dataTransNum)






            imgCount=size(input,4);
            seqImg=[];
            for i=1:imgCount
                inputTemp=input(:,:,:,i);



                inputTemp2=dnnfpga.format.paddingtoDataParallelTransferNumber(inputTemp,dataTransNum,threadNumLimit);


                seqImgTemp=dnnfpga.format.convert3DInputToDDRVectorFormatConv4(inputTemp2,dataTransNum);


                seqImg=cat(2,seqImg,seqImgTemp');
            end
        end

    end

    methods(Access=protected)
        function cc=resolveCC(this)

            convp=this.getConvProcessor();
            conv_cc=convp.getCC();


            ip0=this.getInputProcessor1();
            ip0_cc=ip0.getCC();


            ip1=this.getInputProcessor1();
            ip1_cc=ip1.getCC();


            op0=this.getInputProcessor1();
            op0_cc=op0.getCC();

            cc.conv=conv_cc;
            cc.ip0=ip0_cc;
            cc.ip1=ip1_cc;
            cc.op0=op0_cc;







            cc.ip0.progLCMemDepth=cc.ip0.layerConfigNumWLimit*1000;
            cc.ip1.progLCMemDepth=cc.ip1.layerConfigNumWLimit*1000;
            cc.op0.progLCMemDepth=cc.op0.layerConfigNumWLimit*1000;

            cc.syncInstFormat=this.getBCC().syncInstFormat;



            debugTagObj=dnnfpga.debug.DebugTagCNN4;
            debugCCParams=debugTagObj.emitCCDebugParameters;
            cc.debug.DebugParams=debugCCParams.DebugParams;


            cc.debug.isCNN4Debug=true;

        end

        function lc=resolveLCPerLayer(~,~)
            assert(false,'dnnfpga.processorbase.cnnProcessor doesn''t resolve individual layers');
            lc=[];
        end

        function syncSeqLC=getSyncSeqLC(this,syncIR,params)


            maxPCNum=2^(this.getCC().syncInstFormat.newPCMax-this.getCC().syncInstFormat.newPCMin);
            sa=dnnfpga.processorbase.syncAssembler(this.getCC().syncInstFormat,maxPCNum);


            scriptConv=this.emitConvSyncScript({syncIR.conv});
            syncSeqLC.conv=sa.build(scriptConv);
            if(strcmpi(dnnfpgafeature('Debug'),'on'))
                dnnfpga.processorbase.syncAssembler.str2file(scriptConv,'scriptConv.s');
            end


            scriptIP0=this.emitIP0SyncScript({syncIR.ip0});
            syncSeqLC.ip0=sa.build(scriptIP0);
            if(strcmpi(dnnfpgafeature('Debug'),'on'))
                dnnfpga.processorbase.syncAssembler.str2file(scriptIP0,'scriptIP0.s');
            end


            scriptIP1=this.emitIP1SyncScript({syncIR.ip1},params);
            syncSeqLC.ip1=sa.build(scriptIP1);
            if(strcmpi(dnnfpgafeature('Debug'),'on'))
                dnnfpga.processorbase.syncAssembler.str2file(scriptIP1,'scriptIP1.s');
            end


            scriptOP0=this.emitOP0SyncScript({syncIR.op0});
            syncSeqLC.op0=sa.build(scriptOP0);
            if(strcmpi(dnnfpgafeature('Debug'),'on'))
                dnnfpga.processorbase.syncAssembler.str2file(scriptOP0,'scriptOP0.s');
            end
        end


        function script=emitConvSyncScript(this,syncIR)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','convsynchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','convsynctail.s'));
            body=sprintf('st:	Set(''id'', ''0'', ''limit'', ''1'')\n');

            for i=1:length(syncIR)
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i);

                for j=1:syncIR{i}
                    body=sprintf('%sst%d_%d:SW(''s'',''0'',''w'',''%%OpR'',''wlogic'',''OR'') \\\\ wait opReady\n',body,i,j);
                    body=sprintf('%s\tSW(''s'',''%%R0'',''w'',''%%V0'',''wlogic'',''AND'') \\\\ send R0,R1 to IP0,IP1 and wait\n',body);








                    tileNumStr=sprintf('tiles_%d',i-1);
                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'') \\\\%s = %d\n',body,syncIR{i},tileNumStr,syncIR{i});
                    body=sprintf('%s\tCall(''func'', ''%%foo'')\n',body);
                end
                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i);
            end
            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);




            body=sprintf('%s\tReset()\n',body);


            script=[head,body,tail];
        end

        function script=emitIP0SyncScript(this,syncIRs)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip0synchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip0synctail_new.s'));
            body=sprintf('');
            body=sprintf('%s\tSW(''s'', ''%%ProcessorStart'', ''w'', ''0'')  \\\\ send processor start signal\n',body);
            for i=1:length(syncIRs)
                syncIR=syncIRs{i};
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i-1);
                body=sprintf('%s\tSW(''s'', ''%%LayerStart'', ''w'', ''0'')  \\\\ send layer start signal\n',body);
                for j=1:length(syncIR)








                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'')  \\\\ tile_%d_%d\n',body,syncIR(j),i-1,j-1);
                    body=sprintf('%s\tCall(''func'', ''%%foo'')\n',body);
                end

                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i-1);
            end
            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);





            body=sprintf('%s\tReset()\n',body);


            script=[head,body,tail];
        end

        function script=emitIP1SyncScript(this,syncIRs,params)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip1synchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','ip1synctail.s'));
            body=sprintf('st:	Set(''id'', ''0'', ''limit'', ''1'')\n');
            for i=1:length(syncIRs)
                syncIR=syncIRs{i};
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i-1);
                body=sprintf('%s\t\\\\ no need to load the 1st tile\n',body);
                for j=1:length(syncIR)
                    if(j==1)
                        body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%ConvR1'')\n',body);
                        body=sprintf('%s\tSW(''s'', ''%%V'', ''w'', ''%%ConvA'')\n',body);
                    end
                end
                body=sprintf('%s\tSW(''s'', ''%%A'', ''w'', ''0'') \\\\ all tile done\n',body);
                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i-1);
            end




            script=[head,body,tail];
        end

        function script=emitOP0SyncScript(this,syncIRs)
            head=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','op0synchead.s'));
            tail=fileread(fullfile(matlabroot,'toolbox','dnnfpga','dnnfpga','+dnnfpga','+processorbase','op0synctail_new.s'));
            body=[];
            for i=1:length(syncIRs)
                syncIR=syncIRs{i};
                body=sprintf('%s\t\\\\ layer %d starts here\n',body,i-1);
                if i==length(syncIRs)
                    body=sprintf('%sst%d:SW(''s'',''0'',''w'',''%%FcR'') \\\\ wait ready FcR\n',body,i);
                end
                for j=1:length(syncIR)








                    body=sprintf('%s\tSW(''s'', ''%%R'', ''w'',''%%ConvV'') \\\\ send ready to conv and wait\n',body);
                    body=sprintf('%s\tSet(''id'', ''1'', ''limit'', ''%d'')  \\\\ tile_%d_%d\n',body,syncIR(j),i-1,j-1);


                    if(j==length(syncIR)&&i==length(syncIRs))
                        body=sprintf('%s\tCall(''func'', ''%%foo2'')\n',body);
                    else
                        body=sprintf('%s\tCall(''func'', ''%%foo1'')\n',body);
                    end
                end

                body=sprintf('%s\tSW(''s'', ''%%LayerDone'', ''w'', ''0'')  \\\\ send layer done signal\n',body);
                body=sprintf('%s\t\\\\ layer %d ends here\n',body,i-1);
            end


            body=sprintf('%s\tSW(''s'', ''%%CentralPause'', ''w'', ''0'')  \\\\ send central pause signal\n',body);
            body=sprintf('%s\tSW(''s'', ''0'', ''w'', ''%%CentralStart'')  \\\\ wait central start signal\n',body);





            body=sprintf('%s\tReset()\n',body);


            script=[head,body,tail];
        end

        function output=flattenLayerData(this,layerData,prop)
            numLayers=length(layerData);
            fields=fieldnames(layerData(1).(prop));
            numFields=length(fields);
            for i=1:numFields
                output.(fields{i})=layerData(1).(prop).(fields{i});
                for j=2:numLayers
                    output.(fields{i})=[output.(fields{i}),layerData(j).(prop).(fields{i})];
                end
            end
        end
    end

    methods(Access=protected,Static=true)

        function[imageTilePos,result]=resolve(tileInfo,param)



            resultSize=tileInfo.outImageSize;
            tileSize=tileInfo.atomicResultSize;
            tileIdx=tileInfo.imageTileIdx;

            tilePos=[tileIdx(1),tileIdx(1)+1,tileIdx(2),tileIdx(2)+1].*[tileSize(1),tileSize(1),tileSize(2),tileSize(2)];
            tilePos(2)=min(tilePos(2),resultSize(1));
            tilePos(4)=min(tilePos(4),resultSize(2));
            resultTilePos=tilePos;


            result.finalWriteSize=[resultTilePos(2)-resultTilePos(1),resultTilePos(4)-resultTilePos(3)];
            result.resultTilePos=resultTilePos;




            dilatedWeightSize=(tileInfo.weightSize(1:2)-1).*(param.dilationMode)+1;
            strideSize=[tileInfo.strideSize(1),tileInfo.strideSize(1),tileInfo.strideSize(2),tileInfo.strideSize(2)];



            if strcmpi(param.type,'FPGA_Lrn2D')
                imageTilePos=tilePos.*strideSize;
            elseif strcmpi(param.type,'FPGA_Unpool2D')||strcmpi(param.type,'FPGA_TransposedConv')


                imageTilePos=ceil(tilePos./repmat(tileInfo.weightSize(1:2),[2,1]).');
            elseif strcmpi(param.type,'FPGA_Maxpool2D')&&(param.maxpoolType==1||param.maxpoolType==2)


                imageTilePos=tilePos.*strideSize;
                if tilePos(2)==resultSize(1)
                    imageTilePos(2)=param.origImgSize(1);
                end
                if tilePos(4)==resultSize(2)
                    imageTilePos(4)=param.origImgSize(2);
                end
            else







                imageTilePos=tilePos.*strideSize+[0,dilatedWeightSize(1),0,dilatedWeightSize(2)]-[0,1,0,1].*strideSize;
            end


















            imagePaddingSize=param.paddingMode;
            [imageTilePos,tilePaddingSize1]=dnnfpga.processorbase.conv4Processor.padOuterEdges(imageTilePos,tileInfo.imageSize,imagePaddingSize);




            imageTilePos(1)=max(imageTilePos(1),0);
            imageTilePos(3)=max(imageTilePos(3),0);
            imageTilePos(2)=min(imageTilePos(2),tileInfo.imageSize(1));
            imageTilePos(4)=min(imageTilePos(4),tileInfo.imageSize(2));


            result.tilePaddingSize=tilePaddingSize1;

            result.tileStridePhase=[0,0];






            if strcmpi(param.type,'FPGA_Unpool2D')||strcmpi(param.type,'FPGA_TransposedConv')
                unpoolRemainder=dnnfpga.processorbase.conv4Processor.calcUnpoolRemainder(imageTilePos,tilePos,tileInfo.weightSize);
                result.unpoolRemainder=unpoolRemainder;
            else
                result.unpoolRemainder=[0,0];
            end
        end

        function unpoolRemainder=calcUnpoolRemainder(imageTilePos,tilePos,weightSize)
            difference=tilePos-imageTilePos.*(repmat(weightSize(1:2),[2,1]).');
            unpoolRemainder=[difference(2),difference(4)];
        end

        function[tilePos,tilePaddingSize]=padOuterEdges(tilePos,imageSize,paddingSize)























            tilePaddingSize=zeros(1,4);


            tilePos(1)=tilePos(1)-paddingSize(1);

            if(tilePos(1)<0)
                tilePaddingSize(1)=-tilePos(1);
                assert(tilePaddingSize(1)<=paddingSize(1));
            end


            tilePos(2)=tilePos(2)-paddingSize(1);
            if(tilePos(2)>imageSize(1))
                tilePaddingSize(2)=(tilePos(2)-imageSize(1));
                if tilePaddingSize(2)>paddingSize(2)
                    tilePaddingSize(2)=paddingSize(2);
                end
            end


            tilePos(3)=tilePos(3)-paddingSize(3);

            if(tilePos(3)<0)
                tilePaddingSize(3)=-tilePos(3);
                assert(tilePaddingSize(3)<=paddingSize(3));
            end


            tilePos(4)=tilePos(4)-paddingSize(3);
            if(tilePos(4)>imageSize(2))
                tilePaddingSize(4)=(tilePos(4)-imageSize(2));
                if tilePaddingSize(4)>paddingSize(4)
                    tilePaddingSize(4)=paddingSize(4);
                end
            end
        end

        function[tilePos,tilePaddingSize]=padInnerEdges(tilePos,imageSize,paddingSize)

            postPaddingPoint=tilePos(1)-paddingSize(1);
            if(postPaddingPoint>0)
                prePad(1)=paddingSize(1);
            else
                prePad(1)=tilePos(1);
            end
            tilePos(1)=tilePos(1)-prePad(1);

            postPaddingPoint=tilePos(2)+paddingSize(1);
            if(postPaddingPoint<imageSize(1))
                postPad(1)=paddingSize(1);
            else
                postPad(1)=max(0,imageSize(1)-tilePos(2));
            end
            tilePos(2)=tilePos(2)+postPad(1);

            postPaddingPoint=tilePos(3)-paddingSize(2);
            if(postPaddingPoint>0)
                prePad(2)=paddingSize(2);
            else
                prePad(2)=tilePos(3);
            end
            tilePos(3)=tilePos(3)-prePad(2);

            postPaddingPoint=tilePos(4)+paddingSize(2);
            if(postPaddingPoint<imageSize(2))
                postPad(2)=paddingSize(2);
            else
                postPad(2)=max(0,imageSize(2)-tilePos(4));
            end
            tilePos(4)=tilePos(4)+postPad(2);

            tilePaddingSize=[prePad(1),postPad(1),prePad(2),postPad(2)];
        end

        function resultTilePosS=strideImagePos(resultTilePos,strideSize,stridePhase)

            resultTilePosS=floor(([(resultTilePos(1)+stridePhase(1)),resultTilePos(2)-(resultTilePos(1)+stridePhase(1)),(resultTilePos(3)+stridePhase(2)),resultTilePos(4)-(resultTilePos(3)+stridePhase(2))])./[strideSize(1),strideSize(1),strideSize(2),strideSize(2)]);

            if(mod((resultTilePos(2)-(resultTilePos(1)+stridePhase(1))),strideSize(1))~=0)
                resultTilePosS(2)=resultTilePosS(2)+1;
            end
            resultTilePosS(2)=resultTilePosS(2)+resultTilePosS(1);
            if(mod((resultTilePos(4)-(resultTilePos(3)+stridePhase(2))),strideSize(2))~=0)
                resultTilePosS(4)=resultTilePosS(4)+1;
            end
            resultTilePosS(4)=resultTilePosS(4)+resultTilePosS(3);

        end

        function convIR=createConvIR(param)
            convIR=param;

            convIR.memDirection=1;
            convIR.type=param.type;
            convIR.phase=[param.phase,'-conv'];

            convIR.outImgSize=convIR.finalWriteSize;
            convIR.origImgSize(1)=convIR.imageTilePos(2)-convIR.imageTilePos(1);
            convIR.origImgSize(2)=convIR.imageTilePos(4)-convIR.imageTilePos(3);
        end

        function ioIR=createIOPIR(param,isIP,name,memSel)
            if(isIP)
                ioIR.type='FPGA_InputP';
                ioIR.Ylimit=param.origImgSize(1);
                ioIR.Xlimit=param.origImgSize(2);

                ioIR.deltaX=param.imageTilePos(4)-param.imageTilePos(3);
                ioIR.deltaY=param.imageTilePos(2)-param.imageTilePos(1);
                ioIR.deltaZ=param.inputFeatureNum;

                ioIR.X=param.imageTilePos(3);
                ioIR.Y=param.imageTilePos(1);
                ioIR.Z=0;

                ioIR.DDR_request_start_addr=param.DDRAddrA;
            else
                ioIR.type='FPGA_OutputP';
                ioIR.Ylimit=param.outImgSize(1);
                ioIR.Xlimit=param.outImgSize(2);

                ioIR.deltaX=param.resultTilePos(4)-param.resultTilePos(3);
                ioIR.deltaY=param.resultTilePos(2)-param.resultTilePos(1);
                ioIR.deltaZ=param.outputFeatureNum;

                ioIR.X=param.resultTilePos(3);
                ioIR.Y=param.resultTilePos(1);
                ioIR.Z=0;

                ioIR.DDR_request_start_addr=param.DDRAddrB;





                if param.lastLayer
                    if~param.hasFC
                        ioIR.DDR_request_start_addr=param.DDRAddrResult;
                    end
                end
            end
            ioIR.phase=[param.phase,'-',name];
            ioIR.Z=0;
            ioIR.memSelect=memSel;
            ioIR.inputSource=1;
            ioIR.firstLayer=param.firstLayer;
            ioIR.lastLayer=param.lastLayer;

        end
    end
end





