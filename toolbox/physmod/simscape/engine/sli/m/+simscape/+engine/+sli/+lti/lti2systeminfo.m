function sysInfo=lti2systeminfo(mxLtiData,mxSinkData)




    mxIn=mxLtiData.mIn;
    mxOut=mxLtiData.mOut;
    nx=mxLtiData.nx;

    hasStates=(nx>0);
    graphInd=mxLtiData.graphInd;
    mxChecksum=mxLtiData.checksum;


    sinksNeeded=mxSinkData.hasLogFcn;







    outputMap=[];
    count=0;
    for j=1:length(mxOut)
        for k=1:(mxOut(j).m*mxOut(j).n)
            count=count+1;
            outputMap{j,k}=count;%#ok
        end
    end









    ind2demux=cell(1,count);

    numOutputs=count;

    sysInfo=simscape.compiler.sli.SystemInfo;





    inputInfos=cell(length(mxIn),1);
    numInputs=0;
    inputDims=zeros(length(mxIn),1);
    for ind=1:length(mxIn)
        inputInfo=simscape.compiler.sli.InputInfo;

        inputInfoInfo=struct('Dimension',[mxIn(ind).m,mxIn(ind).n],...
        'Identifier',mxIn(ind).identifier,...
        'Name',mxIn(ind).name,...
        'Unit',mxIn(ind).unit);
        inputInfo.Info=inputInfoInfo;
        inputDims(ind)=mxIn(ind).m*mxIn(ind).n;
        numInputs=numInputs+inputDims(ind);
        inputInfo.UdotRequired=zeros(inputDims(ind),1);
        inputInfo.Port=cell(1,inputDims(ind));

        inputInfos{ind}=inputInfo;
    end

    outputInfos=cell(length(mxOut),1);
    for ind=1:length(mxOut)
        outputInfo=simscape.compiler.sli.OutputInfo;

        outputInfoInfo=struct('Dimension',[mxOut(ind).m,mxOut(ind).n],...
        'Identifier',mxOut(ind).identifier,...
        'Name',mxOut(ind).name,...
        'Unit',mxOut(ind).unit);

        outputInfo.Info=outputInfoInfo;
        outputInfo.Port=cell(1,mxOut(ind).m*mxOut(ind).n);

        outputInfos{ind}=outputInfo;
    end



    blocks={};
    localConnections={};



    stateType=sprintf('built-in/SimscapeLtiState');
    stateName=sprintf('LTI_STATE_%d',graphInd);
    column=4;
    stateBlockInfo=simscape.compiler.sli.BlockInfo(...
    stateType,...
    stateName,...
    column,...
    {...
    'Checksum',mat2str(mxChecksum),...
    'MxParameter',mxLtiData...
    }...
    );

    blocks{end+1}=stateBlockInfo;


    if sinksNeeded
        sinkType=sprintf('built-in/SimscapeSinkBlock');
        sinkName=sprintf('LTI_SINK_%d',graphInd);
        column=4;
        sinkBlockInfo=simscape.compiler.sli.BlockInfo(...
        sinkType,...
        sinkName,...
        column,...
        {...
        'MxParameter',mxSinkData...
        }...
        );
        blocks{end+1}=sinkBlockInfo;
    end

    if numOutputs


        patternToRows=containers.Map('KeyType','double','ValueType','any');
        for rowInd=1:size(mxLtiData.outputPatternMap,1)
            patternInd=mxLtiData.outputPatternMap(rowInd)+1;
            if(isKey(patternToRows,patternInd))
                patternToRows(patternInd)=[patternToRows(patternInd),rowInd];
            else
                patternToRows(patternInd)=rowInd;
            end
        end



        numOutputBlk=size(patternToRows,1);
        column=4;
        for outputBlkInd=1:numOutputBlk

            outputType=sprintf('built-in/SimscapeLtiOutput');
            outputName=sprintf('LTI_OUTPUT_%d_%d',graphInd,outputBlkInd);


            outParamStruct=struct('LtiData',mxLtiData,'BlockIndex',outputBlkInd-1);
            outBlockInfo=simscape.compiler.sli.BlockInfo(...
            outputType,...
            outputName,...
            column,...
            {...
            'MxParameter',outParamStruct...
            }...
            );
            blocks{end+1}=outBlockInfo;

            demuxType=sprintf('built-in/Demux');
            demuxBlkInd=outputBlkInd;
            demuxName=sprintf('LTI_DEMUX_%d_%d',graphInd,demuxBlkInd);
            numOutputPorts=size(patternToRows(outputBlkInd),2);
            demuxBlockInfo=simscape.compiler.sli.BlockInfo(...
            demuxType,...
            demuxName,...
            column+1,...
            {...
            'Outputs',sprintf('%d',numOutputPorts)...
            }...
            );
            blocks{end+1}=demuxBlockInfo;

            ind2demux=updateInd2demux(ind2demux,patternToRows(outputBlkInd),outputBlkInd);
        end
    elseif hasStates&&~sinksNeeded




        terminatorType=sprintf('built-in/Terminator');
        terminatorName=sprintf('LTI_TERMINATOR_%d_1',graphInd);
        column=4;
        terminatorBlockInfo=simscape.compiler.sli.BlockInfo(...
        terminatorType,...
        terminatorName,...
        column,...
        {}...
        );
        blocks{end+1}=terminatorBlockInfo;
    end



    muxType=sprintf('built-in/Mux');
    column=6;
    for ind=1:length(mxOut)
        muxName=sprintf('LTI_MUX_%d_%d',graphInd,ind);
        muxBlockInfo=simscape.compiler.sli.BlockInfo(...
        muxType,...
        muxName,...
        column,...
        {'Inputs',sprintf('%d',mxOut(ind).m*mxOut(ind).n)}...
        );

        blocks{end+1}=muxBlockInfo;
    end







    count=0;
    for i=1:length(mxIn)
        for j=1:(inputDims(i))
            count=count+1;
            pin=sprintf('%s/%d',stateName,count);
            inputInfos{i}.Port{j}=[inputInfos{i}.Port{j},{pin}];
        end
    end


    hasRtps=simscape.engine.sli.internal.hasRuntimeParameters(mxLtiData.parameterInfo);
    if hasRtps

        [rtpTopos.integers,count]=...
        localConstructRtpTopo(graphInd,stateName,count,mxLtiData.parameterInfo,'integers');
        [rtpTopos.indices,count]=...
        localConstructRtpTopo(graphInd,stateName,count,mxLtiData.parameterInfo,'indices');
        [rtpTopos.logicals,count]=...
        localConstructRtpTopo(graphInd,stateName,count,mxLtiData.parameterInfo,'logicals');
        [rtpTopos.reals,~]=...
        localConstructRtpTopo(graphInd,stateName,count,mxLtiData.parameterInfo,'reals');
    end



    if sinksNeeded
        count=0;
        for i=1:length(mxIn)
            for j=1:inputDims(i)
                count=count+1;
                pin=sprintf('%s/%d',sinkName,count);
                inputInfos{i}.Port{j}=[inputInfos{i}.Port{j},{pin}];
            end
        end
    end



    if numOutputs
        count=0;
        for i=1:length(mxIn)
            for j=1:(inputDims(i))
                count=count+1;
                for outputBlkInd=1:numOutputBlk
                    outputName=sprintf('LTI_OUTPUT_%d_%d',graphInd,outputBlkInd);
                    pin=sprintf('%s/%d',outputName,count);
                    inputInfos{i}.Port{j}=[inputInfos{i}.Port{j},{pin}];
                end
            end
        end
    end



    if hasStates
        if sinksNeeded
            pin=sprintf('%s/%d',sinkName,numInputs+1);
            newLine={[stateName,'/1'],pin};
            localConnections{end+1}=newLine;
        end
        if numOutputs
            for outputBlkInd=1:numOutputBlk
                outputName=sprintf('LTI_OUTPUT_%d_%d',graphInd,outputBlkInd);
                pin=sprintf('%s/%d',outputName,numInputs+1);
                newLine={[stateName,'/1'],pin};
                localConnections{end+1}=newLine;
            end
        elseif~sinksNeeded
            newLine={[stateName,'/1'],[terminatorName,'/1']};
            localConnections{end+1}=newLine;
        end
    end


    if numOutputs
        for outputBlkInd=1:numOutputBlk
            outputName=sprintf('LTI_OUTPUT_%d_%d',graphInd,outputBlkInd);
            demuxName=sprintf('LTI_DEMUX_%d_%d',graphInd,outputBlkInd);
            newLine={[outputName,'/1'],[demuxName,'/1']};
            localConnections{end+1}=newLine;
        end
    end


    for muxInd=1:length(mxOut)
        for inputPortInd=1:(mxOut(muxInd).m*mxOut(muxInd).n)
            gInd=outputMap{muxInd,inputPortInd};
            demuxInd=ind2demux{gInd}(1);
            outputPortInd=ind2demux{gInd}(2);
            srcPin=sprintf('LTI_DEMUX_%d_%d/%d',graphInd,demuxInd,outputPortInd);
            dstPin=sprintf('LTI_MUX_%d_%d/%d',graphInd,muxInd,inputPortInd);
            newLine={srcPin,dstPin};
            localConnections{end+1}=newLine;
        end
    end


    for i=1:length(mxOut)
        outputInfos{i}.Port=[sprintf('LTI_MUX_%d_%d/1',graphInd,i)];
    end





    sysInfo.NumInputs=numInputs;
    sysInfo.Input=inputInfos;
    sysInfo.InputOrder=1;

    sysInfo.NumOutputs=numOutputs;
    sysInfo.Output=outputInfos;

    sysInfo.FundamentalSampleTime=0.0;

    sysInfo.Block=blocks;
    sysInfo.Connection=localConnections;

    if hasRtps
        slTopoBlocks={};
        slTopoLines={};
        [slTopoBlocks,slTopoLines]=...
        localAppendRtpTopo(slTopoBlocks,slTopoLines,rtpTopos.integers);
        [slTopoBlocks,slTopoLines]=...
        localAppendRtpTopo(slTopoBlocks,slTopoLines,rtpTopos.indices);
        [slTopoBlocks,slTopoLines]=...
        localAppendRtpTopo(slTopoBlocks,slTopoLines,rtpTopos.logicals);
        [slTopoBlocks,slTopoLines]=...
        localAppendRtpTopo(slTopoBlocks,slTopoLines,rtpTopos.reals);
        assert(~isempty(slTopoBlocks));
        assert(~isempty(slTopoLines));
        sysInfo.SlTopoData=struct('Blocks',{slTopoBlocks},'Lines',{slTopoLines});
    else
        sysInfo.SlTopoData=[];
    end
end

function map=updateInd2demux(map,rowsInd,demuxBlkInd)
    outputPortInd=0;
    for i=rowsInd
        outputPortInd=outputPortInd+1;
        map{i}=[demuxBlkInd,outputPortInd];
    end
end

function[rtpTopo,portCount]=localConstructRtpTopo(...
    graphInd,stateBlock,portCount,parameterInfo,parameterClass)
    paramsOfClass=parameterInfo.(parameterClass);
    numParamsOfClass=numel(unique({paramsOfClass.path}));
    if numParamsOfClass>0

        params=struct('integers',[],'indices',[],'logicals',[],'reals',[]);
        params.(parameterClass)=paramsOfClass;
        rtpTopo=simscape.engine.sli.shared.RtpTopo(...
        sprintf('RTP_%s',parameterClass),graphInd,params,...
        'Mux',{'Inputs',sprintf('%d',numParamsOfClass)});
        portCount=portCount+1;
        rtpTopo.connectTo(stateBlock,portCount);
    else
        rtpTopo=[];
    end
end

function[blocks,lines]=localAppendRtpTopo(blocks,lines,rtpTopo)
    if isempty(rtpTopo)
        return
    end
    data=rtpTopo.slTopoData();
    blocks=[blocks,data.Blocks];
    lines=[lines,data.Lines];
end
