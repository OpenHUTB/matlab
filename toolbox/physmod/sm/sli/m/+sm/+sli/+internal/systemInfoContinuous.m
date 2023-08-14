function sysInfo=systemInfoContinuous(dae,idx,mp,sp,solver)


























    assert(dae.NumMajorModes==0)
    hasOutputs=...
    (dae.NumStates+...
    dae.NumDiscreteStates+...
    dae.NumModes)>0;




    outputMap=[];
    count=0;
    for j=1:length(dae.Output)
        ioInfo=dae.Output(j);
        for k=1:prod(ioInfo.Dimension)
            count=count+1;
            outputMap{j,k}=count;%#ok
        end
    end








    outputIndices=zeros(dae.NumOutputs,1);
    ofm=dae.OutputFunctionMap;
    for j=0:max([ofm;-1])
        aux=find(ofm==j);
        outputIndices(aux)=1:length(aux);
    end





    localBlocks=[];
    localConnections=[];

    solver=getfullname(solver);
    key=nesl_solverkey(solver);
    daeKey=sprintf('%s_%d',key,idx);

    op={};








    inputInfos=cell(length(dae.Input),1);
    udot_req=dae.UDOT_REQ(dae.inputs);
    if dae.InputOrder==2
        nu=dae.NumInputs;
        udot_req=max(udot_req(1:nu/2),2*udot_req(nu/2+1:end));
    end
    count=1;
    for i=1:length(dae.Input)

        inputInfo=simscape.compiler.sli.InputInfo;

        si=dae.Input(i);

        inputInfo.Info=dae.Input(i);
        inputInfo.UdotRequired=udot_req(count:count+prod(inputInfo.Info.Dimension)-1);
        count=count+prod(inputInfo.Info.Dimension);
        inputInfo.Port=cell(1,prod(si.Dimension));

        inputInfos{i}=inputInfo;
    end








    outputInfos=cell(length(dae.Output),1);
    for i=1:length(dae.Output)

        outInfo=simscape.compiler.sli.OutputInfo;

        outInfo.Info=dae.Output(i);
        outInfo.Port='';

        outputInfos{i}=outInfo;
    end



    engineInputPortMap=containers.Map;





    hasRtpPort=simscape.engine.sli.internal.hasRuntimeParameters(dae.ParameterInfo);
    cgSupportFcn=@(execBlock,regKey)...
    simscape.engine.sli.dae.RtpCgSupport.support(solver,idx,execBlock,regKey);

    s=struct('daeKey',daeKey,'daeIdx',0,'cgSupportFcn',cgSupportFcn);
    rtpBlockType='built-in/SimscapeRtp';
    rtpBlockParameters={'MxParameters',simscape_dae_rtp_data(s)};
    rtpTopo=simscape.engine.sli.shared.RtpTopo(...
    'RTP',idx,dae.ParameterInfo,rtpBlockType,rtpBlockParameters);






    checksum=[dae.checksum;pm_hash('md5',sp)];

    stateName=sprintf('STATE_%d',idx);
    blockInfo=simscape.compiler.sli.BlockInfo(...
    'built-in/SimscapeExecutionBlock',...
    stateName,...
    4,...
    {...
    'DynamicSystemName',daeKey,...
    'Checksum',mat2str(checksum),...
    'Category','STATE',...
    'Index',mat2str(0)...
    }...
    );




    count=0;
    for i=1:length(dae.Input)
        si=dae.Input(i);
        for k=1:prod(si.Dimension)
            count=count+1;
            pin=sprintf('%s/%d',stateName,count);
            inputInfos{i}.Port{k}=[inputInfos{i}.Port{k},{pin}];
        end
    end

    engineInputPortMap(stateName)=ones(1,count);
    if hasRtpPort


        engineInputPortMap(stateName)=[engineInputPortMap(stateName),0];
        rtpPort=numel(engineInputPortMap(stateName));
        rtpTopo.connectTo(stateName,rtpPort);
    end

    localBlocks{end+1}=blockInfo;




    sinkName=sprintf('SINK_%d',idx);
    modelName=bdroot(solver);
    cgLogSupportFcn=@(execBlock,regKey)...
    simscape.engine.sli.dae.RtwCgLogFcnSupport.support(...
    solver,idx,execBlock,regKey);

    s=struct('mxDaePtr',dae,...
    'mxModelName',modelName,...
    'daeKey',daeKey,...
    'daeIdx',0,...
    'cgSupportFcn',cgLogSupportFcn);
    mxSinkData=simscape_dae_sink_data(s);
    blockInfo=simscape.compiler.sli.BlockInfo(...
    'built-in/SimscapeSinkBlock',...
    sinkName,...
    4,...
    {...
    'MxParameter',mxSinkData,...
    }...
    );


    localBlocks{end+1}=blockInfo;




    count=0;
    for i=1:length(dae.Input)
        si=dae.Input(i);
        for k=1:prod(si.Dimension)
            count=count+1;
            pin=sprintf('%s/%d',sinkName,count);
            inputInfos{i}.Port{k}=[inputInfos{i}.Port{k},{pin}];
        end
    end


    newLines=lConnectToStateOutput(stateName,...
    sinkName,...
    dae,...
    hasOutputs);
    localConnections=[localConnections,newLines];




    for j=0:max([ofm;-1])
        if any(ofm==j)







            opVal=NetworkEngine.OutputParameters;
            opVal.DaeIndex=0;
            opVal.OutputFunctionIndex=j;
            op{end+1}=opVal;%#ok




            outputName=sprintf('OUTPUT_%d_%d',idx,j);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/SimscapeExecutionBlock',...
            outputName,...
            4,...
            {...
            'DynamicSystemName',daeKey,...
            'Checksum',mat2str(0),...
            'Category','OUTPUT',...
            'Index',mat2str(length(op)-1)...
            }...
            );

            localBlocks{end+1}=blockInfo;%#ok




            count=0;
            for i=1:length(dae.Input)
                si=dae.Input(i);
                for k=1:prod(si.Dimension)
                    count=count+1;
                    pin=sprintf('%s/%d',outputName,count);
                    inputInfos{i}.Port{k}=[inputInfos{i}.Port{k},{pin}];
                end
            end




            newLines=lConnectToStateOutput(stateName,...
            outputName,...
            dae,...
            hasOutputs);
            localConnections=[localConnections,newLines];%#ok
            nOutPorts=length(find(ofm==j));




            engineInputPortMap(outputName)=ones(1,count+numel(newLines));
            if hasRtpPort


                engineInputPortMap(outputName)=[engineInputPortMap(outputName),0];
                rtpPort=numel(engineInputPortMap(outputName));
                rtpTopo.connectTo(outputName,rtpPort);
            end




            demuxName=sprintf('OUTPUT_DEMUX_%d_%d',idx,j);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/Demux',...
            demuxName,...
            5,...
            {...
            'Outputs',sprintf('%d',nOutPorts)...
            }...
            );

            localBlocks{end+1}=blockInfo;%#ok




            inputLine={[outputName,'/1'],[demuxName,'/1']};
            localConnections{end+1}=inputLine;%#ok

        end
    end




    for j=1:length(dae.Output)

        ioInfo=dae.Output(j);

        numPort=prod(ioInfo.Dimension);




        muxName=sprintf('OUTPUT_MUX_%d_%d',idx,j);
        blockInfo=simscape.compiler.sli.BlockInfo(...
        'built-in/Mux',...
        muxName,...
        6,...
        {...
        'Inputs',sprintf('%d',numPort)...
        }...
        );
        localBlocks{end+1}=blockInfo;%#ok




        outputInfos{j}.Port=[muxName,'/1'];




        for k=1:numPort
            globalIdx=outputMap{j,k};
            demuxName=sprintf('OUTPUT_DEMUX_%d_%d',idx,ofm(globalIdx));
            srcPin=sprintf('%s/%d',demuxName,outputIndices(globalIdx));
            dstPin=sprintf('%s/%d',muxName,k);
            localConnections{end+1}={srcPin,dstPin};%#ok
        end
    end





    sysInfo=simscape.compiler.sli.SystemInfo;


    sysInfo.NumInputs=dae.NumInputs;
    sysInfo.InputOrder=dae.InputOrder;


    assert(dae.FundamentalSampleTime==0)
    sysInfo.FundamentalSampleTime=0.0;


    sysInfo.NumOutputs=dae.NumOutputs;

    sysInfo.Input=inputInfos;



    for bi=1:length(localBlocks)
        lb=localBlocks{bi};

        if strcmp(lb.Type,'built-in/SimscapeExecutionBlock')

            cgSupportFcn=@simscape.engine.sli.dae.DaeCgSupport.support;

            lb.Parameters=...
            [lb.Parameters...
            ,{'MxParameters',struct('dae',dae,...
            'solverName',solver,...
            'modelParameters',mp,...
            'solverParameters',sp,...
            'outputParameters',{op},...
            'isEngineInputPort',engineInputPortMap(lb.Name),...
            'cgSupportFcn',cgSupportFcn)}];
        end
        localBlocks{bi}=lb;
    end

    sysInfo.Block=localBlocks;

    sysInfo.Connection=localConnections;

    sysInfo.Output=outputInfos;

    sysInfo.SlTopoData=rtpTopo.slTopoData();


    if simscape.engine.sli.internal.hasRuntimeParameters(dae.ParameterInfo)
        rtpDaes=[0];%#ok
    else
        rtpDaes=[];
    end


    rtwLogDaes=[0];%#ok<NBRAK>


    nesl_registersimulatorgroup(daeKey,{dae},sp,mp,op,rtpDaes,rtwLogDaes);
end

function lines=lConnectToStateOutput(stateName,destName,dae,hasOutputs)

    lines=[];
    if hasOutputs
        src=[stateName,'/1'];
        dst=sprintf('%s/%d',destName,dae.NumInputs/dae.InputOrder+1);
        lines{end+1}={src,dst};
    end
end
