function[stats,slTopoData,blockMap]=nesl_setupsimulation(sp,solver,sysinfos,inputInfo,outputInfo,connections,leaveActivated)






























































































    stats=struct('srcPath',{},...
    'dstPath',{},...
    'filterOrder',{},...
    'timeConstant',{});




    slTopoData=struct('Blocks',[],...
    'Lines',[]);




    for i=1:length(outputInfo)
        if~iscell(outputInfo(i).dst)
            outputInfo(i).dst={outputInfo(i).dst};
        end
    end





    lAssertUniqueNamesInStruct({inputInfo.src});
    lAssertUniquePorts([outputInfo.src]);
    lAssertUniquePorts([connections.src]);





    lAssertUniquePorts([inputInfo.dst,connections.dst]);
    lAssertUniqueNamesInStruct([outputInfo.dst]);








    solver=getfullname(solver);
    sParams=lMaskParams(solver);

    simrfCall=sParams.FrequencyDomain;




    if simrfCall
        muxName1_nInputs=zeros(length(sysinfos),1);
        try
            simrfSolverBlk=get_param(solver,'Parent');
            simrfSolverParams=lMaskParams(simrfSolverBlk);
            spf=simrfSolverParams.SamplesPerFrame;
        catch
            spf=1;
        end
        for i=1:length(sysinfos)
            sysinfo=sysinfos{i};
            nNP=0;


            for j=1:length(inputInfo)
                if~any([inputInfo(j).dst.dae])
                    continue
                end
                try
                    if~strcmpi(get_param(inputInfo(j).src.block,'PseudoPeriodic'),'on')
                        nNP=nNP+1;
                    end
                catch

                end
            end


            l=((sysinfo.NumInputs-nNP)/(sysinfo.InputOrder*spf))+nNP;
            lCheckIo(cellfun(@(a)a.Info,sysinfo.Input(:),'UniformOutput',false),l);
            lCheckIo(cellfun(@(a)a.Info,sysinfo.Output(:),'UniformOutput',false),sysinfo.NumOutputs/spf);
        end

    else
        spf=1;
        for i=1:length(sysinfos)
            sysinfo=sysinfos{i};
            lCheckIo(cellfun(@(a)a.Info,sysinfo.Input(:),'UniformOutput',false),sysinfo.NumInputs/sysinfo.InputOrder);
            lCheckIo(cellfun(@(a)a.Info,sysinfo.Output(:),'UniformOutput',false),sysinfo.NumOutputs);
        end
    end




    inputMap=[];
    for i=1:length(sysinfos)
        sysinfo=sysinfos{i};
        count=0;
        for j=1:length(sysinfo.Input)
            ioInfo=sysinfo.Input{j}.Info;
            for k=1:prod(ioInfo.Dimension)
                count=count+1;
                inputMap{i,j,k}=count;
            end
        end
    end




    inputPins=cell(length(sysinfos),1);
    for i=1:length(inputInfo)



        for j=1:length(inputInfo(i).dst)
            port=inputInfo(i).dst(j);
            sysinfo=sysinfos{port.dae};
            ioInfo=sysinfo.Input{port.index}.Info;
            for k=1:prod(ioInfo.Dimension)
                src=sprintf('INPUT_%d_%d_%d',i,j,k);
                pin=sprintf('%s/1',src);
                inputPins{port.dae}{inputMap{port.dae,port.index,k}}=pin;
            end
        end
    end
    for i=1:length(connections)



        for j=1:length(connections(i).dst)
            port=connections(i).dst(j);
            sysinfo=sysinfos{port.dae};
            ioInfo=sysinfo.Input{port.index}.Info;
            for k=1:prod(ioInfo.Dimension)
                src=sprintf('INTERNAL_%d_%d_%d',i,j,k);
                pin=sprintf('%s/1',src);
                inputPins{port.dae}{inputMap{port.dae,port.index,k}}=pin;
            end
        end
    end




    solverBlocks=[];
    solverLines=[];








    activeOutputs=cell(length(sysinfos),1);
    for i=1:length(sysinfos)



        activeOutputs{i}=false(length(sysinfos{i}.Output),1);
    end
    for i=1:length(outputInfo)



        port=outputInfo(i).src;
        activeOutputs{port.dae}(port.index)=true;
    end
    for i=1:length(connections)



        port=connections(i).src;
        activeOutputs{port.dae}(port.index)=true;
    end




    for i=1:length(sysinfos)
        sysinfo=sysinfos{i};

        for j=1:length(sysinfo.Output)
            if activeOutputs{i}(j)==false
                terminatorName=sprintf('SYSINFO_TERMINATOR_%d_%d',i,j);
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Terminator',...
                terminatorName,...
                4,...
                {...
                }...
                );
                solverBlocks{end+1}=blockInfo;

                outputLine={sysinfo.Output{j}.Port,[terminatorName,'/1']};
                solverLines{end+1}=outputLine;
            end
        end
    end








    for i=1:length(inputInfo)

        inputBlock=inputInfo(i).src.block;
        inputConnector=inputInfo(i).src.connector;
        blockInfos=[];
        lineInfos=[];
        iParams=lMaskParams(inputBlock);




        assert(~(iParams.PseudoPeriodic&&~sParams.FrequencyDomain),...
        'Transient simulation of pseudo-periodic input.');




        dims=[];
        for j=1:length(inputInfo(i).dst)
            port=inputInfo(i).dst(j);
            sysinfo=sysinfos{port.dae};
            ioInfo=sysinfo.Input{port.index};
            dims=[dims;ioInfo.Info.Dimension];
        end
        if size(dims,1)>1
            if~all(all(diff(dims)==0))
                pm_error('physmod:simscape:engine:sli:simsetup:InconsistentPhysicalPortDimensions',...
                ['''',inputBlock,'''']);
            end
        end
        dimension=dims(1,:);
        blkDims=dimension;

        if iParams.PseudoPeriodic

            blkDims(1)=spf*blkDims(1);
        end




        for order=0:2




            tag=lMakeInputTag(inputBlock,order);




            gotoSource=sprintf('input%d/1',order);
            if all(dimension~=1)
                reshapeName=sprintf('RESHAPE_%d',order);
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Reshape',...
                reshapeName,...
                2,...
                {...
                }...
                );
                blockInfos{end+1}=blockInfo;
                lineInfos{end+1}={gotoSource,[reshapeName,'/1']};
                gotoSource=[reshapeName,'/1'];
            end




            gotoName=sprintf('GOTO_%d',order);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/Goto',...
            gotoName,...
            3,...
            {...
            'GotoTag',tag,...
            'TagVisibility','global'...
            }...
            );
            blockInfos{end+1}=blockInfo;
            newLine={gotoSource,[gotoName,'/1']};
            lineInfos{end+1}=newLine;




            fromName=sprintf('INPUT_FROM_%d_%d',i,order);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/From',...
            fromName,...
            1,...
            {...
            'GotoTag',tag,...
            'TagVisibility','global'...
            }...
            );
            solverBlocks{end+1}=blockInfo;




            demuxName=sprintf('INPUT_DEMUX_%d_%d',i,order);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/Demux',...
            demuxName,...
            2,...
            {...
            'Outputs',sprintf('%d',prod(dimension))...
            }...
            );
            solverBlocks{end+1}=blockInfo;
            newLine={[fromName,'/1'],[demuxName,'/1']};
            solverLines{end+1}=newLine;
        end




        orderProvided='0';
        filterOrder='0';
        zeroDers='0';
        switch iParams.FilteringAndDerivatives
        case 'provide'
            orderProvided=iParams.UdotUserProvided;
        case 'filter'
            filterOrder=iParams.SimscapeFilterOrder;
        case 'zero'
            zeroDers='1';
        end




        for j=1:length(inputInfo(i).dst)

            port=inputInfo(i).dst(j);
            sysinfo=sysinfos{port.dae};
            ioInfo=sysinfo.Input{port.index}.Info;




            blockUnit=iParams.Unit;
            sysinfoUnit=ioInfo.Unit;
            lGetConversion(blockUnit,sysinfoUnit,inputBlock);
            linearTerm=lMakeUnitString(blockUnit,sysinfoUnit,'linear');
            offsetTerm='0';
            if iParams.AffineConversion
                offsetTerm=lMakeUnitString(blockUnit,sysinfoUnit,'offset');
            end




            for k=1:prod(ioInfo.Dimension)

                orderRequired=lDiffOrderRequired(...
                sysinfo.Input{port.index},k);




                inputName=sprintf('INPUT_%d_%d_%d',i,j,k);
                if iParams.PseudoPeriodic

                    blockInfo=simscape.compiler.sli.BlockInfo(...
                    'built-in/SimrfInputBlock',...
                    inputName,...
                    3,...
                    {...
                    'Converter',inputBlock,...
                    'SamplesPerFrame',sprintf('%d',spf),...
                    }...
                    );
                else
                    blockInfo=simscape.compiler.sli.BlockInfo(...
                    'built-in/SimscapeInputBlock',...
                    inputName,...
                    3,...
                    {...
                    'Converter',inputBlock,...
                    'Connector',inputConnector,...
                    'Required',mat2str(orderRequired),...
                    'Provided',orderProvided,...
                    'ZeroDers',zeroDers,...
                    'Order',filterOrder,...
                    'Lag',mat2str(iParams.InputFilterTimeConstant),...
                    'Gain',linearTerm,...
                    'Offset',offsetTerm
                    }...
                    );
                end
                solverBlocks{end+1}=blockInfo;




                for order=0:2
                    demuxName=sprintf('INPUT_DEMUX_%d_%d',i,order);
                    newLine={sprintf('%s/%d',demuxName,k),...
                    sprintf('%s/%d',inputName,order+1)};
                    solverLines{end+1}=newLine;
                end

                if simrfCall
                    muxName1_nInputs(port.dae)=muxName1_nInputs(port.dae)+1;
                end

            end
        end




        info=struct('connInfo',...
        struct('blocks',{blockInfos},'lines',{lineInfos}),...
        'data',blkDims);
        nesl_blockregistry(inputBlock,solver,info);
    end




    for i=1:length(sysinfos)




        sysinfo=sysinfos{i};

        for bi=1:length(sysinfo.Block)
            lb=sysinfo.Block{bi};


            if strcmp(lb.Type,'built-in/SimscapeExecutionBlock')
                assert(mod(length(lb.Parameters),2)==0);
                lp=cell(1,length(lb.Parameters));
                for pi=0:(length(lb.Parameters)/2)-1
                    lp{pi*2+1}=lb.Parameters{pi*2+1};
                    lp{pi*2+2}=lb.Parameters{pi*2+2};

                    if strcmp(lb.Parameters{pi*2+1},'SimrfCall')
                        lp{pi*2+2}=mat2str(double(simrfCall));
                    end


                    if strcmp(lb.Parameters{pi*2+1},'MxParameters')
                        lp{pi*2+2}.inputs=inputInfo;
                        lp{pi*2+2}.outputs=outputInfo;
                    end
                end
                lb.Parameters=lp;
            end
            sysinfo.Block{bi}=lb;
        end


        solverBlocks=[solverBlocks,sysinfo.Block];
        solverLines=[solverLines,sysinfo.Connection];



        for bi=1:length(sysinfo.Input)
            bName=sysinfo.Input{bi}.Port;
            if simrfCall
                dName=[];
                for di=1:length(bName)
                    dName{di}=regexprep(bName{di}{1},'STATE','INPUT_MUX_1');
                end
                bName=dName;
            end
            newLines=lConnectToSysinfoInputs(bName,...
            sysinfo,...
            i,...
            bi,...
            inputPins,...
            inputMap);
            solverLines=[solverLines,newLines];
        end

        if simrfCall




            muxName1=sprintf('INPUT_MUX_1_%d',i);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/Mux',...
            muxName1,...
            4,...
            {...
            'Inputs',sprintf('%d',muxName1_nInputs(i))...
            }...
            );
            solverBlocks{end+1}=blockInfo;


            muxName2=sprintf('INPUT_MUX_2_%d',i);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/Mux',...
            muxName2,...
            4,...
            {...
            'Inputs',sprintf('%d',2)...
            }...
            );
            solverBlocks{end+1}=blockInfo;


            newLines={sprintf('%s/%d',muxName1,1),sprintf('%s/%d',muxName2,1)};
            solverLines{end+1}=newLines;%#ok<*AGROW>
        end

    end




    for i=1:length(connections)





        srcPort=connections(i).src;
        srcSysinfo=sysinfos{srcPort.dae};
        srcInfo=srcSysinfo.Output{srcPort.index}.Info;




        demuxConnectionName=sprintf('OUTPUT_DEMUX_CONNECTION_%d',i);
        blockInfo=simscape.compiler.sli.BlockInfo(...
        'built-in/Demux',...
        demuxConnectionName,...
        2,...
        {...
        'Outputs',sprintf('%d',prod(srcInfo.Dimension))...
        }...
        );
        solverBlocks{end+1}=blockInfo;




        newLines={{srcSysinfo.Output{srcPort.index}.Port,[demuxConnectionName,'/1']}};
        solverLines=[solverLines,newLines];

        for j=1:length(connections(i).dst)

            dstPort=connections(i).dst(j);
            dstSysinfo=sysinfos{dstPort.dae};
            dstInfo=dstSysinfo.Input{dstPort.index}.Info;
            srcUnit=sysinfos{srcPort.dae}.Output{srcPort.index}.Info.Unit;
            dstUnit=sysinfos{dstPort.dae}.Input{dstPort.index}.Info.Unit;
            pm_unit(srcUnit,dstUnit);
            linearTerm=lMakeUnitString(srcUnit,dstUnit,'linear');







            needRateTransition=(srcSysinfo.FundamentalSampleTime~=...
            dstSysinfo.FundamentalSampleTime);

            assert(all(dstInfo.Dimension==srcInfo.Dimension),...
            'Failure to catch dimensional mismatch');

            for k=1:prod(dstInfo.Dimension)




                filterOrder=lDiffOrderRequired(...
                sysinfos{dstPort.dae}.Input{dstPort.index},...
                k);




                if prod(dstInfo.Dimension)==1
                    suff='';
                else
                    suff=['(',mat2str(k),')'];
                end
                newStat=struct('srcPath',[srcInfo.Name,suff],...
                'dstPath',[dstInfo.Name,suff],...
                'filterOrder',double(filterOrder),...
                'timeConstant',sp.FilteringTimeConstant);
                stats(end+1)=newStat;




                lastPin=sprintf('%s/%d',demuxConnectionName,k);
                if needRateTransition
                    rateTransitionName=sprintf('RATE_TRANSITION_%d_%d_%d',i,j,k);
                    blockInfo=simscape.compiler.sli.BlockInfo(...
                    'built-in/RateTransition',...
                    rateTransitionName,...
                    1,...
                    {...
                    }...
                    );
                    solverBlocks{end+1}=blockInfo;
                    newLine={lastPin,[rateTransitionName,'/1']};
                    solverLines{end+1}=newLine;
                    lastPin=[rateTransitionName,'/1'];
                end




                inputBlock=sprintf('INTERNAL_%d_%d_%d',i,j,k);
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/SimscapeInputBlock',...
                inputBlock,...
                3,...
                {...
                'Converter',solver,...
                'Required',mat2str(filterOrder),...
                'Provided','0',...
                'ZeroDers','0',...
                'Order',mat2str(filterOrder),...
                'Lag',mat2str(sp.FilteringTimeConstant),...
                'Gain',linearTerm,...
                'Offset','0'
                }...
                );
                solverBlocks{end+1}=blockInfo;
                newLines={{lastPin,[inputBlock,'/1']}...
                ,{'SCALAR_GROUND/1',[inputBlock,'/2']}...
                ,{'SCALAR_GROUND/1',[inputBlock,'/3']}};
                solverLines=[solverLines,newLines];
            end
        end
    end




    for i=1:length(outputInfo)

        port=outputInfo(i).src;
        sysinfo=sysinfos{port.dae};
        outputPort=sysinfo.Output{port.index}.Port;
        ioInfo=sysinfo.Output{port.index}.Info;




        tag=lMakeOutputTag(solver,i);
        gotoName=sprintf('OUTPUT_GOTO_%d',i);
        blockInfo=simscape.compiler.sli.BlockInfo(...
        'built-in/Goto',...
        gotoName,...
        7,...
        {...
        'GotoTag',tag,...
        'TagVisibility','global'...
        }...
        );
        solverBlocks{end+1}=blockInfo;
        newLine={outputPort,[gotoName,'/1']};
        solverLines{end+1}=newLine;




        for j=1:length(outputInfo(i).dst)

            outputBlock=outputInfo(i).dst{j}.block;
            oParams=lMaskParams(outputBlock);




            assert(~(oParams.PseudoPeriodic&&~sParams.FrequencyDomain),...
            'Transient simulation of pseudo-periodic output.');




            blockInfos=[];
            lineInfos=[];




            fromName=sprintf('FROM_OUTPUT_%d_%d',i,j);
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/From',...
            fromName,...
            1,...
            {...
            'GotoTag',tag,...
            'TagVisibility','global'...
            }...
            );
            blockInfos{end+1}=blockInfo;




            eUnit=ioInfo.Unit;
            oUnit=oParams.Unit;


            [oUnit,blockData]=lInheritUnit(eUnit,oUnit);

            lGetConversion(oUnit,eUnit,outputBlock);
            linearTerm=lMakeUnitString(eUnit,oUnit,'linear');
            offsetTerm='0';
            if oParams.AffineConversion
                offsetTerm=lMakeUnitString(eUnit,oUnit,'offset');
            end
            lastPin=[fromName,'/1'];
            if eval(linearTerm)~=1



                gainName='GAIN';
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Gain',...
                gainName,...
                2,...
                {...
                'Gain',linearTerm...
                }...
                );
                blockInfos{end+1}=blockInfo;
                gainPin=[gainName,'/1'];
                lineInfos{end+1}={lastPin,gainPin};
                lastPin=gainPin;
            end
            if eval(offsetTerm)~=0



                constantName='CONSTANT';
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Constant',...
                constantName,...
                2,...
                {...
                'Value',offsetTerm...
                }...
                );
                blockInfos{end+1}=blockInfo;
                constantPin1=[constantName,'/1'];

                sumName='SUM';
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Sum',...
                sumName,...
                3,...
                {...
                }...
                );
                blockInfos{end+1}=blockInfo;
                sumPin1=[sumName,'/1'];
                sumPin2=[sumName,'/2'];
                lineInfos{end+1}={lastPin,sumPin1};
                lineInfos{end+1}={constantPin1,sumPin2};
                lastPin=sumPin1;
            end




            if strcmp(oParams.VectorFormat,'inherit')||all(ioInfo.Dimension~=1)
                reshapeName='RESHAPE';
                blockInfo=simscape.compiler.sli.BlockInfo(...
                'built-in/Reshape',...
                reshapeName,...
                3,...
                {...
                'OutputDimensionality','Customize'...
                ,'OutputDimensions',mat2str(ioInfo.Dimension)...
                }...
                );
                blockInfos{end+1}=blockInfo;
                lineInfos{end+1}={lastPin,[reshapeName,'/1']};
                lastPin=[reshapeName,'/1'];
            end




            convName='UNITCONV';
            blockInfo=simscape.compiler.sli.BlockInfo(...
            'built-in/SignalSpecification',...
            convName,...
            4,...
            {...
            'Unit',''...
            }...
            );
            blockInfos{end+1}=blockInfo;
            convPin=[convName,'/1'];
            lineInfos{end+1}={lastPin,convPin};
            lastPin=convPin;




            lineInfos{end+1}={lastPin,'output/1'};




            connInfo=struct('blocks',{blockInfos},'lines',{lineInfos});
            blockInfo=struct('connInfo',connInfo,'data',blockData);
            nesl_blockregistry(outputBlock,solver,blockInfo);
        end
    end




    if~isempty(connections)
        groundName='SCALAR_GROUND';
        blockInfo=simscape.compiler.sli.BlockInfo(...
        'built-in/Ground',...
        groundName,...
        2,...
        {...
        }...
        );
        solverBlocks{end+1}=blockInfo;
    end




    unconnectedSysinfoInputs=false;
    for i=1:length(sysinfos)
        if i>length(inputPins)
            unconnectedSysinfoInputs=true;
            break;
        end
        sysinfo=sysinfos{i};
        pins=inputPins{i};
        for j=1:length(sysinfo.Input)
            ioInfo=sysinfo.Input{j}.Info;
            for k=1:prod(ioInfo.Dimension)
                sysinfoInput=inputMap{i,j,k};
                if sysinfoInput>length(pins)||isempty(pins{sysinfoInput})
                    unconnectedSysinfoInputs=true;
                    break;
                end
            end
        end
    end

    if unconnectedSysinfoInputs
        groundName='INPUT_GROUND';
        blockInfo=simscape.compiler.sli.BlockInfo(...
        'built-in/Ground',...
        groundName,...
        3,...
        {...
        }...
        );
        solverBlocks{end+1}=blockInfo;
    end




    connInfo=struct('blocks',{solverBlocks},'lines',{solverLines});
    blockInfo=struct('connInfo',connInfo,'data',[]);
    nesl_blockregistry(solver,solver,blockInfo);





    nesl_addedblockregistry();
    lEvalParams(solver,leaveActivated);
    ioBlocks=[{inputInfo.src},[outputInfo.dst]];
    for i=1:length(ioBlocks)
        lEvalParams(ioBlocks{i}.block,leaveActivated);
    end




    for i=1:length(sysinfos)
        sysinfo=sysinfos{i};
        if~isempty(sysinfo.SlTopoData)
            slTopoData.Blocks=[slTopoData.Blocks,sysinfo.SlTopoData.Blocks];
            slTopoData.Lines=[slTopoData.Lines,lReplaceAddedBlocksWithHandles(sysinfo.SlTopoData.Lines)];
        end
    end
    if~isempty(slTopoData.Blocks)&&~iscell(slTopoData.Blocks)
        slTopoData.Blocks={slTopoData.Blocks};
    end
    if~isempty(slTopoData.Lines)&&~iscell(slTopoData.Lines)
        slTopoData.Lines={slTopoData.Lines};
    end

    blockMap=containers.Map;
    for i=1:numel(solverBlocks)
        name=solverBlocks{i}.Name;
        handle=nesl_addedblockregistry(name);
        if~isempty(handle)
            blockMap(name)=Simulink.ID.getSID(handle);
        end
    end


    nesl_addedblockregistry();
end

function lines=lReplaceAddedBlocksWithHandles(lines)
    for i=1:numel(lines)
        lines{i}{1}=llGetHandleIfAddedBlock(lines{i}{1});
        lines{i}{3}=llGetHandleIfAddedBlock(lines{i}{3});
    end

    function out=llGetHandleIfAddedBlock(in)


        out=nesl_addedblockregistry(in);
        if isempty(out)
            out=in;
        end
    end
end

function lAssertUniquePorts(a)

    portSerializer=@(port)sprintf('%d.%d',port.dae,port.index);
    serializedPorts=arrayfun(portSerializer,a,'UniformOutput',false);
    lAssertUniqueNames(serializedPorts);
end

function lAssertUniqueNames(a)

    if~isempty(a)
        a=a(:);
        pm_assert(length(unique(a))==length(a));
    end
end

function lAssertUniqueNamesInStruct(a)

    if~isempty(a)
        a=[a{:}];
        ff=fields(a(1));
        for i=1:numel(ff)
            lAssertUniqueNames({a.(ff{i})});
        end
    end
end

function lCheckIo(io,l)

    if isstruct([io{:}])
        tmp=[io{:}];
        dims={tmp.Dimension}';
    else
        dims=get([io{:}],'Dimension');
    end
    if~iscell(dims)
        dims={dims};
    end
    count=sum(prod(cell2mat(dims),2));
    pm_assert(count>=l,'too few elements');
    pm_assert(count<=l,'too many elements');
end

function out=lMaskParams(block)
    ws=get_param(block,'MaskWSVariables');
    ca=[{ws.Name};cellfun(@lUnwrapIfSlParam,{ws.Value},'UniformOutput',false)];
    out=struct(ca{:});
end

function val=lUnwrapIfSlParam(val)
    if isa(val,'Simulink.Parameter')
        val=val.Value;
    end
end

function tag=lMakeInputTag(block,i)

    tag=lMakeTag(sprintf('%s_%d',lDecapitate(block),i));
end

function tag=lMakeOutputTag(block,i)


    tag=lMakeTag(sprintf('%s_output_%d',lDecapitate(block),i));
end

function tag=lMakeTag(name)

    tag=['NESL_TAG_',dec2hex(pm_crc(name))];
end

function block=lDecapitate(block)



    model=bdroot(block);
    block=block(length(model)+2:end);
end

function order=lDiffOrderRequired(inputinfo,i)

    order=inputinfo.UdotRequired(i);
end

function lines=lConnectToSysinfoInputs(dst,sysinfo,sysidx,portidx,inputPins,inputMap)

    lines=[];
    zero_input='INPUT_GROUND/1';

    pins=inputPins{sysidx};
    ioInfo=sysinfo.Input{portidx}.Info;
    for k=1:prod(ioInfo.Dimension)

        sysinfoInput=inputMap{sysidx,portidx,k};
        dest=dst{k};
        if sysinfoInput<=length(pins)&&~isempty(pins{sysinfoInput})
            lines{end+1}={pins{sysinfoInput},dest};
        else
            lines{end+1}={zero_input,dest};
        end
    end
end

function conversion=lGetConversion(unit1,unit2,block)



    try
        conversion=pm_unit(unit1,unit2);
    catch e
        try
            pm_error('physmod:simscape:engine:sli:simsetup:ConverterUnit',block);
        catch f
            throw(f.addCause(e));
        end
    end
end

function unitString=lMakeUnitString(in,out,mode)

    lQ=@(str)['''',str,''''];
    unitString=['pm_unit(',lQ(in),', ',lQ(out),', ',lQ(mode),')'];
end

function lEvalParams(block,leaveActivated)




    persistent FCN;
    if isempty(FCN)
        FCN=pmsl_private('pmsl_evalparams');
    end

    blockH=get_param(block,'Handle');
    blockN=getfullname(blockH);
    evalKey=[blockN,'/EVAL_KEY'];
    evalKeyH=get_param(evalKey,'Handle');


    nesl_blockregistry(block,true);
    if~leaveActivated
        FCN(evalKeyH);
        nesl_blockregistry(block,false);
    end
end

function[oUnit,blockData]=lInheritUnit(eUnit,oUnit)


    blockData=[];
    if strcmp(oUnit,pm_inherit_id())
        oUnit=eUnit;
        blockData=struct('Unit',eUnit);
    end
end


