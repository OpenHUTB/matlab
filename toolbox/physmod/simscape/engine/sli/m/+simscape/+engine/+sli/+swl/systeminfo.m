function sysInfo=systeminfo(data,solver)





    sysInfo=simscape.compiler.sli.SystemInfo;


    stateName=sprintf('SWL_STATE_%d',data.graphInd);
    demuxName=sprintf('SWL_DEMUX_%d',data.graphInd);


    ins=data.in;
    inputInfos=cell(length(data.in),1);
    inputDims=zeros(length(data.in),1);
    count=0;
    for ind=1:length(data.in)
        inputInfo=simscape.compiler.sli.InputInfo;
        inputInfoInfo=struct('Dimension',[ins(ind).m,ins(ind).n],...
        'Identifier',ins(ind).identifier,...
        'Name',ins(ind).name,...
        'Unit',ins(ind).unit);
        inputInfo.Info=inputInfoInfo;
        num=ins(ind).m*ins(ind).n;
        inputInfo.UdotRequired=zeros(num,1);
        inputInfo.Port=cell(1,num);

        for j=1:num
            count=count+1;
            pin=sprintf('%s/%d',stateName,count);
            inputInfo.Port{j}=[inputInfo.Port{j},{pin}];
        end
        inputInfos{ind}=inputInfo;
        inputDims(ind)=num;
    end


    outs=data.out;
    outputInfos=cell(length(data.out),1);
    outputDims=zeros(length(data.out),1);
    for ind=1:length(data.out)
        outputInfo=simscape.compiler.sli.OutputInfo;
        outputInfoInfo=struct('Dimension',[outs(ind).m,outs(ind).n],...
        'Identifier',outs(ind).identifier,...
        'Name',outs(ind).name,...
        'Unit',outs(ind).unit);
        outputInfo.Info=outputInfoInfo;
        num=outs(ind).m*outs(ind).n;
        outputInfo.Port=sprintf('%s/%d',demuxName,ind);
        outputInfos{ind}=outputInfo;
        outputDims(ind)=num;
    end

    blocks={};




    parameterInfo=data.parameterInfo();
    hasRtpPort=simscape.engine.sli.internal.hasRuntimeParameters(parameterInfo);

    cgSupportFcn=@(execBlock)...
    simscape.engine.sli.swl.RtpCgSupport.support(solver,execBlock,data.graphInd);
    s=struct('swlData',data,'cgSupportFcn',cgSupportFcn);
    rtpBlockType='built-in/SimscapeRtp';
    rtpBlockParameters={'MxParameters',simscape_swl_rtp_data(s)};
    rtpTopo=simscape.engine.sli.shared.RtpTopo(...
    'RTP',data.graphInd,parameterInfo,rtpBlockType,rtpBlockParameters);


    isSwlInputPort=ones(1,count);
    if hasRtpPort
        isSwlInputPort(end+1)=0;
    end
    stateType=sprintf('built-in/SimscapeSwlState');
    column=4;
    stateData=struct('swlData',data,'isSwlInputPort',isSwlInputPort);
    stateBlockInfo=simscape.compiler.sli.BlockInfo(...
    stateType,...
    stateName,...
    column,...
    {...
    'Checksum',mat2str(data.checksum),...
    'MxParameter',stateData...
    }...
    );
    blocks{end+1}=stateBlockInfo;

    localConnections={};

    if hasRtpPort
        rtpPort=find(~isSwlInputPort);
        assert(numel(rtpPort)==1);
        rtpTopo.connectTo(stateName,rtpPort);
    end

    if~isempty(data.out)


        demuxType=sprintf('built-in/Demux');
        column=5;
        demuxDims=outputDims;
        if numel(demuxDims)==1

            demuxDims=1;
        end
        demuxBlockInfo=simscape.compiler.sli.BlockInfo(...
        demuxType,...
        demuxName,...
        column,...
        {...
        'Outputs',mat2str(demuxDims)...
        }...
        );
        blocks{end+1}=demuxBlockInfo;


        newLine={[stateName,'/1'],[demuxName,'/1']};
        localConnections{end+1}=newLine;

    end


    if~isempty(data.sinkData)
        sinkData=data.sinkData;

        sinkName=sprintf('SWL_SINK_%d',data.graphInd);


        sinkType=sprintf('built-in/SimscapeSinkBlock');
        column=4;
        sinkBlockInfo=simscape.compiler.sli.BlockInfo(...
        sinkType,...
        sinkName,...
        column,...
        {...
        'MxParameter',sinkData...
        }...
        );
        blocks{end+1}=sinkBlockInfo;


        count=0;
        for i=1:length(data.in)
            for j=1:inputDims(i)
                count=count+1;
                pin=sprintf('%s/%d',sinkName,count);
                inputInfos{i}.Port{j}=[inputInfos{i}.Port{j},{pin}];
            end
        end


        idx=2;
        if isempty(data.out)
            idx=1;
        end
        port=sprintf('%s/%d',stateName,idx);
        pin=sprintf('%s/%d',sinkName,sum(inputDims)+1);
        newLine={port,pin};
        localConnections{end+1}=newLine;
    end


    sp=data.solverParameters;
    sysInfo.NumInputs=sum(inputDims);
    sysInfo.Input=inputInfos;
    sysInfo.InputOrder=1;
    sysInfo.NumOutputs=sum(outputDims);
    sysInfo.Output=outputInfos;
    sysInfo.FundamentalSampleTime=sp.LocalSolverSampleTime;
    sysInfo.Block=blocks;
    sysInfo.Connection=localConnections;
    sysInfo.SlTopoData=rtpTopo.slTopoData();

end
