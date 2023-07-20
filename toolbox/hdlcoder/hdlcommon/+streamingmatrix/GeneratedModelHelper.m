classdef GeneratedModelHelper




    methods(Static,Access=public)
        function obj=getGMHelper(topN,dutPath)
            obj=streamingmatrix.GeneratedModelHelper(false,topN,dutPath);
        end

        function obj=getVNLHelper(topN,dutPath)
            obj=streamingmatrix.GeneratedModelHelper(true,topN,dutPath);
        end
    end


    methods(Access=public)
        function drawGMInputOutputSubsystems(this)
            assert(~this.isVNL);

            this.createInputOutputSubsystems('Input streaming','Output collection');
        end
    end


    methods(Access=public)
        function replaceGMInputOutputSubsystems(this,inputSSName,outputSSName)
            assert(this.isVNL);









            [gmInputSubsys,~]=this.getSrc(this.dutPath,1);



            [gmOutputSubsysCell,~]=this.getDsts(this.dutPath,1);
            assert(numel(gmOutputSubsysCell)==1);
            gmOutputSubsys=gmOutputSubsysCell{1};



            for i=1:this.numIns
                portNumStr=num2str(i);
                this.deleteLine(gmInputSubsys,portNumStr,this.dutPath,portNumStr);
            end

            for i=1:this.numOuts
                portNumStr=num2str(i);
                this.deleteLine(this.dutPath,portNumStr,gmOutputSubsys,portNumStr);
            end






            for i=1:this.numOrigIns
                [srcBlk,srcPortNumStr]=this.getSrc(gmInputSubsys,i);
                dutPortNumStr=num2str(i);
                this.deleteLine(srcBlk,srcPortNumStr,gmInputSubsys,dutPortNumStr);
                this.addLine(srcBlk,srcPortNumStr,this.dutPath,dutPortNumStr);
            end

            for i=1:this.numOrigOuts
                [dstBlks,dstPortNumStrs]=this.getDsts(gmOutputSubsys,i);
                dutPortNumStr=num2str(i);

                for j=1:numel(dstBlks)
                    this.deleteLine(gmOutputSubsys,dutPortNumStr,dstBlks{j},dstPortNumStrs{j});
                    this.addLine(this.dutPath,dutPortNumStr,dstBlks{j},dstPortNumStrs{j});
                end
            end



            delete_block(gmInputSubsys);
            delete_block(gmOutputSubsys);

            this.createInputOutputSubsystems(inputSSName,outputSSName);
        end

        function addOriginalDUTInputOutputSubsystems(this,origDUTPath,inputSSName,outputSSName)
            inpSS=this.createOriginalInputSubsystem(origDUTPath,inputSSName);
            [outSS,inBlks]=this.createOutputCheckSubsystem(origDUTPath,outputSSName);

            for i=1:numel(this.portInfo.streamedOutPorts)
                streamInfo=this.portInfo.streamedOutPorts(i);
                this.checkStreamedOutput(streamInfo,outSS,inBlks)
            end

            Simulink.BlockDiagram.arrangeSystem(inpSS);
            Simulink.BlockDiagram.arrangeSystem(outSS);
        end
    end

    properties(GetAccess=public,SetAccess=immutable)

        isVNL(1,1)logical


        topN(1,1)


        portInfo(1,1)streamingmatrix.AllPortInfo


        dutPath(1,:)char


        topSS(1,:)char


        numIns(1,1)double


        numOrigIns(1,1)double


        numOuts(1,1)double




        nonStreamedInputMap containers.Map


        numOrigOuts(1,1)double


        createdSSWidth(1,1)double=10;



        createdSSDist(1,1)double=30;
    end


    methods(Access=private)
        function this=GeneratedModelHelper(isVNL,topN,dutPath)
            this.isVNL=isVNL;
            this.topN=topN;
            this.portInfo=streamingmatrix.getStreamedPorts(topN);
            this.dutPath=dutPath;
            this.topSS=get_param(dutPath,'Parent');
            this.numIns=numel(topN.PirInputPorts);
            this.numOrigIns=numel(this.portInfo.streamedInPorts)+...
            numel(this.portInfo.nonStreamedInPorts);
            this.numOuts=numel(topN.PirOutputPorts);
            this.numOrigOuts=numel(this.portInfo.streamedOutPorts)+...
            numel(this.portInfo.nonStreamedOutPorts);
            setModelDynamicMemoryAllocForStreamingMLFB(this);
            setDUTAtomicOff(this);
            this.nonStreamedInputMap=containers.Map('KeyType','double',...
            'ValueType','any');

            this.fillNonStreamedInputMap;
        end




        function createInputOutputSubsystems(this,inputSSName,outputSSName)
            [inpSS,inpInBlks,inpOutBlks]=this.createInputSubsystem(inputSSName);
            [outSS,outInBlks,outOutBlks]=this.createOutputSubsystem(outputSSName);

            for i=1:numel(this.portInfo.streamedInPorts)
                streamInfo=this.portInfo.streamedInPorts(i);
                this.driveStreamedInput(streamInfo,inpSS,inpInBlks,inpOutBlks);
                this.receiveReadyOutput(streamInfo,outSS,outInBlks);
            end

            for i=1:this.numOrigIns



                if~this.shouldTranslateInput(i)
                    this.driveNonTranslatedInput(i,inpSS,inpInBlks,inpOutBlks);
                end
            end

            for i=1:numel(this.portInfo.streamedOutPorts)
                streamInfo=this.portInfo.streamedOutPorts(i);
                this.receiveStreamedOutput(streamInfo,outSS,outInBlks,outOutBlks);
                this.driveReadyInput(streamInfo,inpSS,inpOutBlks);
            end

            for i=1:numel(this.portInfo.externalDelayPorts)
                delayInfo=this.portInfo.externalDelayPorts(i);
                this.driveDelayInput(delayInfo,inpSS,inpOutBlks);
                this.receiveDelayOutput(delayInfo,outSS,outInBlks);
            end

            Simulink.BlockDiagram.arrangeSystem(inpSS);
            Simulink.BlockDiagram.arrangeSystem(outSS);
        end




        function finalizeSubsystem(this,ssPath,referenceSSPath,leftOrRight)
            assert(ismember(leftOrRight,{'left','right'}));



            origPos=get_param(referenceSSPath,'Position');
            newPos=origPos;

            if strcmp(leftOrRight,'left')
                newPos(1)=origPos(1)-this.createdSSDist-this.createdSSWidth;
                newPos(3)=origPos(1)-this.createdSSDist;
            else
                newPos(1)=origPos(3)+this.createdSSDist;
                newPos(3)=origPos(3)+this.createdSSDist+this.createdSSWidth;
            end

            set_param(ssPath,'Position',newPos);
            set_param(ssPath,'MaskDisplay','disp('''')');
            set_param(ssPath,'BackgroundColor','cyan');
        end





        function[imgSize,serializationRatio]=getImgInfo(~,streamInfo)
            dataPort=streamInfo.data;
            smt=dataPort.getStreamingMatrixTag;
            tp=dataPort.Signal.Type;

            imgSize=[smt.getOrigNumRows,smt.getOrigNumCols];

            if isa(tp,'hdlcoder.tp_array')
                currSigSize=double(tp.Dimensions);
            else
                currSigSize=1;
            end

            serializationRatio=prod(imgSize)/prod(currSigSize);
        end
    end


    methods(Access=private)
        function fillNonStreamedInputMap(this)
            if isempty(this.portInfo.nonStreamedInPorts)
                return;
            end



            compRefNumToFirstStreamedIdx=containers.Map;

            for i=1:this.numOrigIns
                if this.isStreamedInput(i)
                    inSig=this.topN.PirInputSignals(i);
                    recv=inSig.getReceivers;
                    assert(isscalar(recv));

                    recvRefNum=recv.Owner.RefNum;

                    if~compRefNumToFirstStreamedIdx.isKey(recvRefNum)
                        compRefNumToFirstStreamedIdx(recvRefNum)=i;
                    end
                end
            end



            for i=1:this.numOrigIns
                if~this.isStreamedInput(i)
                    inSig=this.topN.PirInputSignals(i);
                    recv=inSig.getReceivers;
                    recvRefNum=recv(1).Owner.RefNum;

                    if isscalar(recv)&&compRefNumToFirstStreamedIdx.isKey(recvRefNum)
                        streamedIdx=compRefNumToFirstStreamedIdx(recvRefNum);




                        if this.nonStreamedInputMap.isKey(streamedIdx)
                            currNonStreamedPorts=this.nonStreamedInputMap(streamedIdx);
                            this.nonStreamedInputMap(streamedIdx)=[currNonStreamedPorts,i];
                        else
                            this.nonStreamedInputMap(streamedIdx)=i;
                        end
                    end
                end
            end
        end

        function res=shouldTranslateInput(this,inpIdx)
            res=this.isStreamedInput(inpIdx);

            if~res
                mapVals=this.nonStreamedInputMap.values;
                mapVals=[mapVals{:}];
                res=ismember(inpIdx,mapVals);
            end
        end

        function res=isStreamedInput(this,inpIdx)
            hP=this.topN.PirInputPorts(inpIdx);
            res=hP.hasStreamingMatrixTag;
        end

        function nonStreamedInIdxs=getNonStreamedIdxsForStreamedInput(this,inpIdx)
            if this.nonStreamedInputMap.isKey(inpIdx)
                nonStreamedInIdxs=this.nonStreamedInputMap(inpIdx);
            else
                nonStreamedInIdxs=[];
            end
        end

        function res=isStreamedOutput(this,outIdx)
            hP=this.topN.PirOutputPorts(outIdx);
            res=hP.hasStreamingMatrixTag;
        end
    end


    methods(Access=private)





        function[ssPath,inBlks,outBlks]=createInputSubsystem(this,ssName)
            ssPath=this.addBlock('built-in/Subsystem',this.topSS,ssName);

            inBlks=cell(1,this.numOrigIns);
            for i=1:this.numOrigIns


                inputName=[this.topN.PirInputPorts(i).Name,'_orig'];
                inBlks{i}=this.addInput(ssPath,inputName);


                dutPortNum=num2str(i);
                [srcBlk,srcPort]=this.getSrc(this.dutPath,i);
                this.deleteLine(srcBlk,srcPort,this.dutPath,dutPortNum);


                this.addLine(srcBlk,srcPort,ssPath,dutPortNum);
            end

            outBlks=cell(1,this.numIns);
            for i=1:this.numIns

                outputName=this.topN.PirInputPorts(i).Name;
                outBlks{i}=this.addOutput(ssPath,outputName);


                portNum=num2str(i);
                this.addLine(ssPath,portNum,this.dutPath,portNum);
            end

            this.finalizeSubsystem(ssPath,this.dutPath,'left');
        end

        function driveStreamedInput(this,streamInfo,ssPath,inBlks,outBlks)
            dataPort=streamInfo.data;
            dataIdx=dataPort.PortIndex+1;

            dataIn=inBlks{dataIdx};
            dataOut=outBlks{dataIdx};
            validOut=outBlks{streamInfo.valid.PortIndex+1};

            [imgSize,ratio]=this.getImgInfo(streamInfo);

            if~any(imgSize==1)

                transpose=this.addTranspose(ssPath);
                reshape=this.addReshape(ssPath);
                this.addLine(dataIn,'1',transpose,'1');
                this.addLine(transpose,'1',reshape,'1');

                srcBlk=reshape;
            else
                srcBlk=dataIn;
            end


            serializer=this.addSerializer(ssPath,ratio);
            this.addLine(srcBlk,'1',serializer,'1');


            from=this.addFrom(ssPath,['in_',num2str(dataIdx),'_ready']);



            if~this.nonStreamedInputMap.isKey(dataIdx)

                nonStreamedIdxs=[];
                nonStreamedInList='';
                nonStreamedOutList='';
            else
                nonStreamedIdxs=this.nonStreamedInputMap(dataIdx);
                assert(~isempty(nonStreamedIdxs));

                nonStreamedNames=cell(1,numel(nonStreamedIdxs));
                for i=1:numel(nonStreamedIdxs)
                    hPort=this.topN.PirInputPorts(nonStreamedIdxs(i));
                    nonStreamedNames{i}=matlab.lang.makeValidName(hPort.Name);
                end

                nonStreamedInList=[', '...
                ,strjoin(cellfun(@(n){[n,'_in']},nonStreamedNames),', ')];
                nonStreamedOutList=[', '...
                ,strjoin(cellfun(@(n){[n,'_out']},nonStreamedNames),', ')];
            end






            mlfbTextFormat=[...
'function [%1$s_out_sample, %1$s_valid%3$s] = %1$s_tb('...
            ,'%1$s_sample, %1$s_ready, toggleValid, numHighValidCycles, numLowValidCycles%2$s)',newline...
            ,newline...
            ,'persistent samples validCount sendValid;',newline...
            ,newline...
            ,'if isempty(validCount)',newline...
            ,'    samples = cell(1, 0);',newline...
            ,'    validCount = 0;',newline...
            ,'    sendValid = true;',newline...
            ,'end',newline...
            ,newline...
            ,'samples{end+1} = {%1$s_sample%2$s};',newline...
            ,newline...
            ,'if sendValid && %1$s_ready',newline...
            ,'    %1$s_valid = true;',newline...
            ,'    [%1$s_out_sample%3$s] = samples{1}{:};',newline...
            ,'    samples(1) = [];',newline...
            ,newline...
            ,'    if toggleValid',newline...
            ,'        validCount = validCount + 1;',newline...
            ,newline...
            ,'        if validCount >= numHighValidCycles',newline...
            ,'            validCount = 0;',newline...
            ,'            sendValid = false;',newline...
            ,'        end',newline...
            ,'    end',newline...
            ,'else',newline...
            ,'    %1$s_valid = false;',newline...
            ,'    outputs = cell(1, numel(samples{1}));',newline...
            ,'    for i=1:numel(outputs)',newline...
            ,'        outputs{i} = zeros(size(samples{1}{i}), ''like'', samples{1}{i});',newline...
            ,'    end',newline...
            ,'    [%1$s_out_sample%3$s] = outputs{:};',newline...
            ,newline...
            ,'    if %1$s_ready',newline...
            ,'        validCount = validCount + 1;',newline...
            ,newline...
            ,'        if validCount >= numLowValidCycles',newline...
            ,'            validCount = 0;',newline...
            ,'            sendValid = true;',newline...
            ,'        end',newline...
            ,'    end',newline...
            ,'end',newline...
            ];

            inpName=matlab.lang.makeValidName(dataPort.Name);
            mlfbText=sprintf(mlfbTextFormat,inpName,nonStreamedInList,nonStreamedOutList);
            mlfb=this.addValidReadyMLFB(ssPath,[inpName,'_tb'],mlfbText,'Valid');

            this.addLine(serializer,'1',mlfb,'1');
            this.addLine(from,'1',mlfb,'2');
            this.addLine(mlfb,'1',dataOut,'1');
            this.addLine(mlfb,'2',validOut,'1');

            if this.isVNL



                origGoto=this.addGoto(ssPath,['in_',num2str(dataIdx),'_orig']);
                this.addLine(dataIn,'1',origGoto,'1');
            end



            for i=1:numel(nonStreamedIdxs)
                nonStreamedIdx=nonStreamedIdxs(i);
                mlfbIdxStr=num2str(i+2);

                nonStreamedInp=inBlks{nonStreamedIdx};
                nonStreamedOut=outBlks{nonStreamedIdx};
                upsample=this.addUpsample(ssPath,ratio);

                this.addLine(nonStreamedInp,'1',upsample,'1');
                this.addLine(upsample,'1',mlfb,mlfbIdxStr);
                this.addLine(mlfb,mlfbIdxStr,nonStreamedOut,'1');

                if this.isVNL
                    nonStreamedGoto=this.addGoto(ssPath,['in_',num2str(nonStreamedIdx),'_orig']);
                    this.addLine(nonStreamedInp,'1',nonStreamedGoto,'1');
                end
            end
        end

        function driveReadyInput(this,streamInfo,ssPath,outBlks)

            mlfbTextFormat=[...
'function %1$s_ready = %1$s_ready_tb('...
            ,'toggleReady, numHighReadyCycles, numLowReadyCycles)',newline...
            ,newline...
            ,'persistent readyCount sendReady;',newline...
            ,newline...
            ,'if isempty(readyCount)',newline...
            ,'    readyCount = 0;',newline...
            ,'    sendReady = true;',newline...
            ,'end',newline...
            ,newline...
            ,'if sendReady',newline...
            ,'    %1$s_ready = true;',newline...
            ,newline...
            ,'    if toggleReady',newline...
            ,'        readyCount = readyCount + 1;',newline...
            ,newline...
            ,'        if readyCount >= numHighReadyCycles',newline...
            ,'            readyCount = 0;',newline...
            ,'            sendReady = false;',newline...
            ,'        end',newline...
            ,'    end',newline...
            ,'else',newline...
            ,'    %1$s_ready = false;',newline...
            ,newline...
            ,'    readyCount = readyCount + 1;',newline...
            ,'    if readyCount >= numLowReadyCycles',newline...
            ,'        readyCount = 0;',newline...
            ,'        sendReady = true;',newline...
            ,'    end',newline...
            ,'end',newline...
            ];

            outName=streamInfo.data.Name;
            mlfbText=sprintf(mlfbTextFormat,matlab.lang.makeValidName(outName));
            mlfb=this.addValidReadyMLFB(ssPath,[outName,'_ready_tb'],mlfbText,'Ready');

            readyOut=outBlks{streamInfo.ready.PortIndex+1};
            this.addLine(mlfb,'1',readyOut,'1');

            if this.isVNL




                dataIdx=streamInfo.data.PortIndex+1;
                goto=this.addGoto(ssPath,['out_',num2str(dataIdx),'_ready']);
                this.addLine(mlfb,'1',goto,'1');
            end
        end

        function driveDelayInput(this,delayInfo,ssPath,outBlks)


            outBlk=outBlks{delayInfo.inPort.data.PortIndex+1};



            outIdx=delayInfo.outPort.data.PortIndex+1;
            from=this.addFrom(ssPath,['external_delay_',num2str(outIdx)]);


            this.addLine(from,'1',outBlk,'1');
        end

        function driveNonTranslatedInput(this,inpIdx,ssPath,inBlks,outBlks)

            this.addLine(inBlks{inpIdx},'1',outBlks{inpIdx},'1');



            if this.isVNL
                goto=this.addGoto(ssPath,['in_',num2str(inpIdx),'_orig']);
                this.addLine(inBlks{inpIdx},'1',goto,'1');
            end
        end
    end


    methods(Access=private)






        function[ssPath,inBlks,outBlks]=createOutputSubsystem(this,newSSName)
            ssPath=this.addBlock('built-in/Subsystem',this.topSS,newSSName);

            outBlks=cell(1,this.numOrigOuts);
            for i=1:this.numOrigOuts


                outName=[this.topN.PirOutputPorts(i).Name,'_orig'];
                outBlks{i}=this.addOutput(ssPath,outName);



                dutPortNum=num2str(i);
                [dstBlkPaths,dstPortNumStrs]=this.getDsts(this.dutPath,i);

                for j=1:numel(dstBlkPaths)
                    this.deleteLine(this.dutPath,dutPortNum,dstBlkPaths{j},dstPortNumStrs{j});



                    this.addLine(ssPath,dutPortNum,dstBlkPaths{j},dstPortNumStrs{j});
                end
            end

            inBlks=cell(1,this.numOuts);
            for i=1:this.numOuts

                inName=this.topN.PirOutputPorts(i).Name;
                inBlks{i}=this.addInput(ssPath,inName);



                dutPortNumStr=num2str(i);
                this.addLine(this.dutPath,dutPortNumStr,ssPath,dutPortNumStr);
            end

            this.finalizeSubsystem(ssPath,this.dutPath,'right');
        end

        function receiveStreamedOutput(this,streamInfo,ssPath,inBlks,outBlks)
            dataPort=streamInfo.data;
            dataIdx=dataPort.PortIndex+1;

            dataIn=inBlks{dataIdx};
            dataOut=outBlks{dataIdx};
            validIn=inBlks{streamInfo.valid.PortIndex+1};

            [imgSize,ratio]=this.getImgInfo(streamInfo);

            if ratio>1


                deserializer=this.addDeserializer(ssPath,ratio);
                reshape=this.addReshape(ssPath,[imgSize(2),imgSize(1)]);
                transpose=this.addTranspose(ssPath);

                this.addLine(dataIn,'1',deserializer,'1');
                this.addLine(validIn,'1',deserializer,'2');
                this.addLine(deserializer,'1',reshape,'1');
                this.addLine(reshape,'1',transpose,'1');
                this.addLine(transpose,'1',dataOut,'1');
            end

            if this.isVNL


                dataGoto=this.addGoto(ssPath,['out_',num2str(dataIdx)]);
                validGoto=this.addGoto(ssPath,['out_',num2str(dataIdx),'_valid']);
                this.addLine(dataIn,'1',dataGoto,'1');
                this.addLine(validIn,'1',validGoto,'1');
            end
        end

        function receiveReadyOutput(this,streamInfo,ssPath,inBlks)



            readyIn=inBlks{streamInfo.ready.PortIndex+1};

            dataIdx=streamInfo.data.PortIndex+1;
            goto=this.addGoto(ssPath,['in_',num2str(dataIdx),'_ready']);
            this.addLine(readyIn,'1',goto,'1');
        end

        function receiveDelayOutput(this,delayInfo,ssPath,inBlks)


            outIdx=delayInfo.outPort.data.PortIndex+1;



            inBlk=inBlks{outIdx};
            inValid=inBlks{delayInfo.outPort.valid.PortIndex+1};



            delay=this.addEnabledDelay(ssPath,delayInfo.delayLength);
            this.addLine(inBlk,'1',delay,'1');
            this.addLine(inValid,'1',delay,'2');



            goto=this.addGoto(ssPath,['external_delay_',num2str(outIdx)]);
            this.addLine(delay,'1',goto,'1');
        end
    end


    methods(Access=private)
        function ssPath=createOriginalInputSubsystem(this,origDUTPath,ssName)
            ssPath=this.addBlock('built-in/Subsystem',this.topSS,ssName);

            for i=1:this.numOrigIns

                dutPortNum=num2str(i);
                from=this.addFrom(ssPath,['in_',dutPortNum,'_orig']);


                inputName=this.topN.PirInputPorts(i).Name;
                out=this.addOutput(ssPath,inputName);



                this.addLine(from,'1',out,'1');
                this.addLine(ssPath,dutPortNum,origDUTPath,dutPortNum);
            end

            this.finalizeSubsystem(ssPath,origDUTPath,'left');
        end

        function[ssPath,inBlks]=createOutputCheckSubsystem(this,origDUTPath,ssName)
            ssPath=this.addBlock('built-in/Subsystem',this.topSS,ssName);

            inBlks=cell(1,this.numOrigOuts);
            for i=1:this.numOrigOuts

                outputName=this.topN.PirOutputPorts(i).Name;
                inBlks{i}=this.addInput(ssPath,outputName);


                dutPortNum=num2str(i);
                this.addLine(origDUTPath,dutPortNum,ssPath,dutPortNum);
            end

            this.finalizeSubsystem(ssPath,origDUTPath,'right');
        end

        function checkStreamedOutput(this,streamInfo,ssName,inBlks)
            outputName=streamInfo.data.Name;
            origIn=inBlks{streamInfo.data.PortIndex+1};
            dataIdxStr=num2str(streamInfo.data.PortIndex+1);

            dataCompare=this.addBlock('built-in/Subsystem',ssName,[outputName,'_compare']);
            validCheck=this.addBlock('built-in/Subsystem',ssName,[outputName,'_valid_check']);

            this.fillStreamedDataCompareSubsys(streamInfo,dataCompare);
            this.fillStreamedValidCheckSubsys(streamInfo,validCheck);

            gmDataFrom=this.addFrom(ssName,['out_',dataIdxStr]);
            gmValidFrom=this.addFrom(ssName,['out_',dataIdxStr,'_valid']);
            gmReadyFrom=this.addFrom(ssName,['out_',dataIdxStr,'_ready']);

            this.addLine(origIn,'1',dataCompare,'1');
            this.addLine(gmDataFrom,'1',dataCompare,'2');
            this.addLine(gmValidFrom,'1',dataCompare,'3');

            this.addLine(gmValidFrom,'1',validCheck,'1');
            this.addLine(gmReadyFrom,'1',validCheck,'2');

            Simulink.BlockDiagram.arrangeSystem(dataCompare);
            Simulink.BlockDiagram.arrangeSystem(validCheck);
        end

        function fillStreamedDataCompareSubsys(this,streamInfo,ssPath)
            inOrigData=this.addInput(ssPath,'data_orig');
            inGMData=this.addInput(ssPath,'data');
            inGMValid=this.addInput(ssPath,'valid');



            [imgSize,ratio]=this.getImgInfo(streamInfo);

            if~any(imgSize==1)

                transpose=this.addTranspose(ssPath);
                reshape=this.addReshape(ssPath);
                this.addLine(inOrigData,'1',transpose,'1');
                this.addLine(transpose,'1',reshape,'1');
                origSrcBlk=reshape;
            else
                origSrcBlk=inOrigData;
            end

            origSerializer=this.addSerializer(ssPath,ratio);
            this.addLine(origSrcBlk,'1',origSerializer,'1');



            outputName=streamInfo.data.Name;
            mlfbTextFormat=[...
            'function [matches, origData] = %1$s_compare(origSample, gmSample, gmValid)',newline...
            ,newline...
            ,'persistent origSamples;',newline...
            ,newline...
            ,'if isempty(origSamples)',newline...
            ,'    origSamples = cell(1, 0);',newline...
            ,'end',newline...
            ,newline...
            ,'origSamples{end+1} = origSample;',newline...
            ,'origData = origSamples{1};',newline...
            ,newline...
            ,'if gmValid',newline...
            ,'    origSamples(1) = [];',newline...
            ,newline...
            ,'    matches = isequal(gmSample, origData);',newline...
            ,'else',newline...
            ,'    matches = true;',newline...
            ,'end',newline...
            ];
            mlfb=this.addMLFB(ssPath,[outputName,'_compare'],...
            sprintf(mlfbTextFormat,matlab.lang.makeValidName(outputName)));

            this.addLine(origSerializer,'1',mlfb,'1');
            this.addLine(inGMData,'1',mlfb,'2');
            this.addLine(inGMValid,'1',mlfb,'3');



            assert=this.addAssert(ssPath);
            scope=this.addScope(ssPath,['compare: ',outputName],4);

            this.addLine(mlfb,'1',assert,'1');
            this.addLine(inGMData,'1',scope,'1');
            this.addLine(inGMValid,'1',scope,'2');
            this.addLine(mlfb,'2',scope,'3');
            this.addLine(mlfb,'1',scope,'4');
        end

        function fillStreamedValidCheckSubsys(this,streamInfo,ssPath)
            outputName=streamInfo.data.Name;

            inValid=this.addInput(ssPath,[outputName,'_valid']);
            inReady=this.addInput(ssPath,[outputName,'_ready']);


            notValid=this.addLogic(ssPath,'NOT');
            notValidOrReady=this.addLogic(ssPath,'OR');

            assert=this.addAssert(ssPath);
            scope=this.addScope(ssPath,['check: ',outputName,'_valid'],3);

            this.addLine(inValid,'1',notValid,'1');
            this.addLine(notValid,'1',notValidOrReady,'1');
            this.addLine(inReady,'1',notValidOrReady,'2');
            this.addLine(notValidOrReady,'1',assert,'1');
            this.addLine(inValid,'1',scope,'1');
            this.addLine(inReady,'1',scope,'2');
            this.addLine(notValidOrReady,'1',scope,'3');



            set_param(notValidOrReady,'Name','not valid OR ready');
        end
    end


    methods(Access=private)


        function blkPath=addBlock(~,libPath,subsysPath,blkName)
            blkHandle=add_block(libPath,[subsysPath,'/',blkName],...
            'MakeNameUnique','on');
            blkPath=getfullname(blkHandle);
        end

        function addLine(~,srcBlk,srcPortNumStr,dstBlk,dstPortNumStr)
            ssPath=get_param(srcBlk,'Parent');
            srcPortStr=[get_param(srcBlk,'Name'),'/',srcPortNumStr];
            dstPortStr=[get_param(dstBlk,'Name'),'/',dstPortNumStr];
            add_line(ssPath,srcPortStr,dstPortStr,'AutoRouting','on');
        end

        function deleteLine(~,srcBlk,srcPortNumStr,dstBlk,dstPortNumStr)
            ssPath=get_param(srcBlk,'Parent');
            srcPortStr=[get_param(srcBlk,'Name'),'/',srcPortNumStr];
            dstPortStr=[get_param(dstBlk,'Name'),'/',dstPortNumStr];
            delete_line(ssPath,srcPortStr,dstPortStr);
        end



        function[srcBlkPath,srcPortNumStr]=getSrc(~,blkPath,portNum)
            allSLPortHandles=get_param(blkPath,'PortHandles');

            inPortSLHandle=allSLPortHandles.Inport(portNum);
            inpLine=get_param(inPortSLHandle,'Line');
            srcPortHandle=get_param(inpLine,'SrcPortHandle');
            srcBlkPath=get_param(srcPortHandle,'Parent');
            srcPortNumStr=num2str(get_param(srcPortHandle,'PortNumber'));
        end



        function[dstBlkPaths,dstPortNumStrs]=getDsts(~,blkPath,portNum)
            allSLPortHandles=get_param(blkPath,'PortHandles');

            slPortHandle=allSLPortHandles.Outport(portNum);
            outLine=get_param(slPortHandle,'Line');
            dstPortHandles=get_param(outLine,'DstPortHandle');

            numDstPorts=numel(dstPortHandles);
            dstBlkPaths=cell(1,numDstPorts);
            dstPortNumStrs=cell(1,numDstPorts);

            for i=1:numDstPorts
                dstBlkPaths{i}=get_param(dstPortHandles(i),'Parent');
                dstPortNumStrs{i}=num2str(get_param(dstPortHandles(i),'PortNumber'));
            end
        end

        function inBlk=addInput(this,subsysPath,blkName)
            inBlk=this.addBlock('built-in/Inport',subsysPath,blkName);
            set_param(inBlk,'Position',[0,0,30,14]);
        end

        function outBlk=addOutput(this,subsysPath,blkName)
            outBlk=this.addBlock('built-in/Outport',subsysPath,blkName);
            set_param(outBlk,'Position',[0,0,30,14]);
        end

        function fromBlk=addFrom(this,subsysPath,tag)
            fromBlk=this.addBlock('built-in/From',subsysPath,'From');
            set_param(fromBlk,'Position',[0,0,30,14]);
            set_param(fromBlk,'GotoTag',tag);
            set_param(fromBlk,'TagVisibility','global');
        end

        function gotoBlk=addGoto(this,subsysPath,tag)
            gotoBlk=this.addBlock('built-in/Goto',subsysPath,'Goto');
            set_param(gotoBlk,'Position',[0,0,30,14]);
            set_param(gotoBlk,'GotoTag',tag);
            set_param(gotoBlk,'TagVisibility','global');
        end

        function transposeBlk=addTranspose(this,subsysPath)
            transposeBlk=this.addBlock('built-in/Math',subsysPath,'Transpose');
            set_param(transposeBlk,'Operator','transpose');
            set_param(transposeBlk,'Position',[0,0,30,32]);
        end

        function reshapeBlk=addReshape(this,subsysPath,dimensions)
            reshapeBlk=this.addBlock('built-in/Reshape',subsysPath,'Reshape');
            set_param(reshapeBlk,'Position',[0,0,30,24]);

            if nargin>2
                set_param(reshapeBlk,'OutputDimensionality','Customize');
                set_param(reshapeBlk,'OutputDimensions',mat2str(dimensions));
            end
        end

        function delayBlk=addEnabledDelay(this,subsysPath,delayLength)
            delayBlk=this.addBlock('built-in/Delay',subsysPath,'Delay');
            set_param(delayBlk,'DelayLength',num2str(delayLength));
            set_param(delayBlk,'ShowEnablePort','on');
            set_param(delayBlk,'Position',[0,0,35,34]);
        end

        function serializerBlk=addSerializer(this,subsysPath,ratio)
            serializerBlk=this.addBlock('hdlsllib/HDL Operations/Serializer1D',...
            subsysPath,'Serializer1D');
            set_param(serializerBlk,'Ratio',num2str(ratio));
            set_param(serializerBlk,'Position',[0,0,30,32]);
        end

        function deserializerBlk=addDeserializer(this,subsysPath,ratio)
            deserializerBlk=this.addBlock('hdlsllib/HDL Operations/Deserializer1D',...
            subsysPath,'Deserializer1D');
            set_param(deserializerBlk,'Ratio',num2str(ratio));
            set_param(deserializerBlk,'ValidIn','on');
            set_param(deserializerBlk,'Position',[0,0,30,32]);
        end

        function upsampleBlk=addUpsample(this,subsysPath,ratio)
            upsampleBlk=this.addBlock('built-in/RateTransition',...
            subsysPath,'Rate Transition');
            set_param(upsampleBlk,'Integrity','off');
            set_param(upsampleBlk,'OutPortSampleTimeOpt','Multiple of input port sample time');
            set_param(upsampleBlk,'OutPortSampleTimeMultiple',['1/',num2str(ratio)]);
            set_param(upsampleBlk,'Position',[0,0,40,42]);
        end

        function logicBlk=addLogic(this,subsysPath,op)
            logicBlk=this.addBlock('built-in/Logic',subsysPath,op);
            set_param(logicBlk,'Position',[0,0,30,32]);
            set_param(logicBlk,'Operator',op);
            set_param(logicBlk,'IconShape','distinctive');
        end

        function assertBlk=addAssert(this,subsysPath)
            assertBlk=this.addBlock('built-in/Assertion',subsysPath,'AssertEq');
            set_param(assertBlk,'Position',[0,0,35,28]);
            set_param(assertBlk,'StopWhenAssertionFail','off');
        end

        function scopeBlk=addScope(this,subsysPath,blkName,numIn)
            numPortsStr=num2str(numIn);

            scopeBlk=this.addBlock('built-in/Scope',subsysPath,blkName);

            set_param(scopeBlk,'Position',[0,0,40,54]);
            set_param(scopeBlk,'NumInputPorts',numPortsStr);
            set_param(scopeBlk,'LayoutDimensionsString',['[',numPortsStr,' 1]']);

            for scopeIdx=1:numIn
                set_param(scopeBlk,'ActiveDisplayString',num2str(scopeIdx));
                set_param(scopeBlk,'ShowLegend','on');
            end
        end

        function[mlfbBlk,mlfbSFHandle_out]=addMLFB(this,subsysPath,mlfbName,mlfbText)
            mlfbBlk=this.addBlock('simulink/User-Defined Functions/MATLAB Function',...
            subsysPath,mlfbName);
            mlfbID=sfprivate('block2chart',mlfbBlk);
            mlfbSFHandle=idToHandle(slroot,mlfbID);
            mlfbSFHandle.script=mlfbText;

            if nargout>1
                mlfbSFHandle_out=mlfbSFHandle;
            end
        end

        function mlfbBlk=addValidReadyMLFB(this,subsysPath,mlfbName,mlfbText,validOrReady)
            assert(ismember(validOrReady,{'Valid','Ready'}));
            [mlfbBlk,mlfbSFHandle]=this.addMLFB(subsysPath,mlfbName,mlfbText);

            parameterNames={...
            ['toggle',validOrReady],...
            ['numHigh',validOrReady,'Cycles'],...
            ['numLow',validOrReady,'Cycles']};




            for i=numel(mlfbSFHandle.Inputs):-1:1
                inp=mlfbSFHandle.Inputs(i);

                if ismember(inp.Name,parameterNames)
                    inp.Scope='Parameter';
                    inp.Tunable=false;
                end
            end


            maskDescStr=getString(message(sprintf(...
            'hdlcommon:streamingmatrix:%sTBMaskDescription',validOrReady)));
            toggleDescStr=getString(message(sprintf(...
            'hdlcommon:streamingmatrix:%sTBMaskToggleDescription',validOrReady)));
            numHighCyclesStr=getString(message(sprintf(...
            'hdlcommon:streamingmatrix:%sTBMaskHighCyclesDescription',validOrReady)));
            numLowCyclesStr=getString(message(sprintf(...
            'hdlcommon:streamingmatrix:%sTBMaskLowCyclesDescription',validOrReady)));

            mask=Simulink.Mask.create(mlfbBlk);
            mask.Description=maskDescStr;


            toggleParam=mask.addParameter;
            toggleParam.Name=['toggle',validOrReady];
            toggleParam.Prompt=toggleDescStr;
            toggleParam.Type='checkbox';
            toggleParam.Value='off';
            toggleParam.Tunable='off';


            numHighCyclesParam=mask.addParameter;
            numHighCyclesParam.Name=['numHigh',validOrReady,'Cycles'];
            numHighCyclesParam.Prompt=numHighCyclesStr;
            numHighCyclesParam.Type='edit';
            numHighCyclesParam.Value='1';
            numHighCyclesParam.Tunable='off';


            numLowCyclesParam=mask.addParameter;
            numLowCyclesParam.Name=['numLow',validOrReady,'Cycles'];
            numLowCyclesParam.Prompt=numLowCyclesStr;
            numLowCyclesParam.Type='edit';
            numLowCyclesParam.Value='1';
            numLowCyclesParam.Tunable='off';
        end

        function setModelDynamicMemoryAllocForStreamingMLFB(this)



            if numel(this.portInfo.streamedInPorts)>0
                set_param(bdroot(this.topSS),'MATLABDynamicMemAlloc','on');
            end
        end

        function setDUTAtomicOff(this)





            if numel(this.portInfo.streamedInPorts)>0
                set_param(this.dutPath,'TreatAsAtomicUnit','off');
            end
        end
    end

end


