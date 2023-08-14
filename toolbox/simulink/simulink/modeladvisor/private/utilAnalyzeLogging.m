function[allSrcPortsScope,trueSrcPortsScope,trueSrcPortsScopeNotLogged,redundantLoggingPortsScope]=...
    utilAnalyzeLogging(modelName,scopeName,depth)















    allSrcPortsScope={};
    trueSrcPortsScope={};
    trueSrcPortsScopeNotLogged={};
    redundantLoggingPortsScope={};

    actualSourcePortRef.port={};
    actualSourcePortRef.srcPort={};
    actualSourcePortRef.srcPortNum={};

    internalRefToExternalSourcePort.srcPort={};
    internalRefToExternalSourcePort.srcPortNum={};
    internalRefToExternalSourcePort.intSrcPort={};
    internalRefToExternalSourcePort.intSrcPortNum={};


    init_flag=false;
    lastwarn('');
    termNeeded=false;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try


        o=get_param(modelName,'Object');
        termNeeded=special_engine_init(modelName);


        init_flag=true;

        [allSrcPortsScope,trueSrcPortsScope,trueSrcPortsScopeNotLogged,redundantLoggingPortsScope]=getScopedData(scopeName,depth);
    catch ME



        if init_flag&&termNeeded
            feval(modelName,[],[],[],'term');
        end
        rethrow(ME);
    end

    if init_flag&&termNeeded
        feval(modelName,[],[],[],'term');
    end




    function termNeeded=special_engine_init(modelName)

        termNeeded=false;
        currW=warning('backtrace','off');
        try
            if~strcmp(get_param(modelName,'SimulationStatus'),'initializing')
                feval(modelName,[],[],[],'compileForSizes');
                termNeeded=true;
            end


        catch ME
            warning(currW);
            rethrow(ME);
        end
        warning(currW);





        function[outPort,isStatechart]=loc_getPort(blk_o)













            if isa(blk_o,'Stateflow.Chart')
                sub_o=get_param(blk_o.Path,'object');
                outPort=get_param(sub_o.PortHandles.Outport,'object');
                isStatechart=true;
            else
                outPort=get_param(blk_o.PortHandles.Outport,'object');
                isStatechart=false;
            end





            function[allSrcPorts,trueSrcPorts,trueSrcPorts_not_logged,redundantLoggingPorts]=getScopedData(scopeName,depth)


                optimization=true;


                allSrcPorts={};
                trueSrcPorts={};
                redundantLoggingPorts={};
                trueSrcPorts_not_logged={};

                actualSourcePortRef.port={};
                actualSourcePortRef.srcPort={};
                actualSourcePortRef.srcPortNum={};

                internalRefToExternalSourcePort.srcPort={};
                internalRefToExternalSourcePort.srcPortNum={};
                internalRefToExternalSourcePort.intSrcPort={};
                internalRefToExternalSourcePort.intSrcPortNum={};

                scope_o=get_param(scopeName,'object');



                allBlocks=find_system(scopeName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','All','FollowLinks','off','Type','Block');
                if~isempty(allBlocks)
                    SLBlocks=get_param(allBlocks,'Object');
                    SLBlocks=[SLBlocks{:}];
                else
                    SLBlocks=[];
                end
                sfChart=find(scope_o,'-depth',depth,'-isa','Stateflow.Chart');
                blkList_o=[SLBlocks,sfChart'];


                for i=1:length(blkList_o)
                    try
                        if isa(blkList_o(i),'Simulink.BusSelector')

                            continue;
                        end
                        if isa(blkList_o(i),'Simulink.Block')
                            up=blkList_o(i).up;
                            if isa(up,'Simulink.SubSystem')&&slprivate('is_stateflow_based_block',up.Handle)

                                continue;
                            end
                        end







                        [outPortD,isStatechart]=loc_getPort(blkList_o(i));

                        if isempty(outPortD)

                            continue;
                        end

                        clear outPort;
                        if length(outPortD)<2
                            outPort{1}=outPortD;
                        else
                            outPort=outPortD;
                        end


                        for idx=1:length(outPort)
                            allSrcPorts{end+1}=outPort{idx};
                        end


                        for j=1:length(outPort)


                            dst=outPort{j}.getActualDst;
                            if~isempty(dst)





                                skip_srcPort=utilCheckDestinationPorts(outPort{j});

                                if~skip_srcPort







                                    if optimization&&~isStatechart









                                        dst_port=get_param(dst(1),'object');
                                        src=dst_port.getActualSrc;
                                        if isempty(src)


                                            continue;
                                        end

                                        src_port=get_param(src(1),'object');
                                        try
                                            blk_o=get_param(outPort{j}.Parent,'object');
                                        catch

                                            continue
                                        end
                                        if isequal(src_port,outPort{j})||...
                                            isa(blk_o,'Simulink.ModelReference')
                                            trueSrcPorts{end+1}=outPort{j};
                                        else







                                            if isa(blk_o,'Simulink.Inport')&&isequal(blk_o.up,scope_o)
                                                trueSrcPorts{end+1}=outPort{j};
















                                                if isa(scope_o,'Simulink.BlockDiagram')
                                                    continue
                                                end
                                                port_in=get_param(blk_o.up.PortHandles.Inport(str2double(blk_o.Port)),'object');
                                                src=port_in.getActualSrc;

                                                if~isempty(src)
                                                    [len,wid]=size(src);
                                                    for k=1:len
                                                        srcPort=get_param(src(k),'object');
                                                        if~isempty(srcPort)
                                                            internalRefToExternalSourcePort.srcPort{end+1}=srcPort.Parent;
                                                            internalRefToExternalSourcePort.srcPortNum{end+1}=srcPort.PortNumber;
                                                            internalRefToExternalSourcePort.intSrcPort{end+1}=outPort{j}.Parent;
                                                            internalRefToExternalSourcePort.intSrcPortNum{end+1}=1;
                                                        end
                                                    end
                                                end

                                            else








                                                try
                                                    src_blk_o=get_param(src_port.Parent,'object');
                                                catch

                                                    continue
                                                end
                                                if isa(src_blk_o,'Simulink.SFunction')&&~isempty(strfind(src_blk_o.Tag,'Stateflow S-Function'))









                                                    graph_p=get_param(src_port.getGraphicalDst,'object');
                                                    graph_blk_o=get_param(graph_p.Parent,'object');
                                                    if isa(graph_blk_o,'Simulink.Outport')
                                                        actualSourcePortRef.port{end+1}=[outPort{j}.Parent,':',num2str(outPort{j}.PortNumber)];
                                                        actualSourcePortRef.srcPort{end+1}=[src_blk_o.Parent];
                                                        actualSourcePortRef.srcPortNum{end+1}=str2double(graph_blk_o.Port);
                                                    end
                                                else

                                                    actualSourcePortRef.port{end+1}=[outPort{j}.Parent,':',num2str(outPort{j}.PortNumber)];
                                                    actualSourcePortRef.srcPort{end+1}=[src_port.Parent];
                                                    actualSourcePortRef.srcPortNum{end+1}=src_port.PortNumber;
                                                end
                                            end
                                        end
                                    else









                                        trueSrcPorts{end+1}=outPort{j};

                                    end
                                end

                            else









                                graph_dst=outPort{j}.getGraphicalDst;

                                if isempty(graph_dst)

                                    continue;
                                end




                                graph_dst_port=get_param(graph_dst(1),'object');
                                actual_src=graph_dst_port.getActualSrc;

                                if isempty(actual_src)

                                    continue;
                                end
                                idx=find(actual_src>1);
                                isThisGoOn=false;
                                for kk=1:length(idx)
                                    try
                                        actual_src_port=get_param(actual_src(idx(kk)),'object');
                                        dst=actual_src_port.getActualDst;
                                        if isempty(dst)


                                            continue;
                                        else
                                            isThisGoOn=true;
                                            break;
                                        end
                                    catch

                                    end
                                end

                                if~isThisGoOn
                                    continue;
                                end

                                skip_srcPort=utilCheckDestinationPorts(actual_src_port);

                                if~skip_srcPort


                                    if optimization&&~isStatechart








                                        blk_o=get_param(outPort{j}.Parent,'object');
                                        if isa(blk_o,'Simulink.ModelReference')
                                            trueSrcPorts{end+1}=outPort{j};
                                        elseif isa(blk_o,'Simulink.Inport')&&isequal(blk_o.up,scope_o)
                                            trueSrcPorts{end+1}=outPort{j};

















                                            port_in=get_param(blk_o.up.PortHandles.Inport(str2double(blk_o.Port)),'object');
                                            src=port_in.getActualSrc;

                                            if~isempty(src)
                                                [len,wid]=size(src);
                                                for k=1:len
                                                    srcPort=get_param(src(k),'object');
                                                    if~isempty(srcPort)
                                                        internalRefToExternalSourcePort.srcPort{end+1}=srcPort.Parent;
                                                        internalRefToExternalSourcePort.srcPortNum{end+1}=srcPort.PortNumber;
                                                        internalRefToExternalSourcePort.intSrcPort{end+1}=outPort{j}.Parent;
                                                        internalRefToExternalSourcePort.intSrcPortNum{end+1}=1;
                                                    end
                                                end
                                            end

                                        else








                                            src_port=actual_src_port;
                                            try
                                                src_blk_o=get_param(src_port.Parent,'object');
                                            catch

                                                continue
                                            end
                                            if isa(src_blk_o,'Simulink.SFunction')&&~isempty(strfind(src_blk_o.Tag,'Stateflow S-Function'))









                                                graph_p=get_param(src_port.getGraphicalDst,'object');
                                                graph_blk_o=get_param(graph_p.Parent,'object');
                                                if isa(graph_blk_o,'Simulink.Outport')
                                                    actualSourcePortRef.port{end+1}=[outPort{j}.Parent,':',num2str(outPort{j}.PortNumber)];
                                                    actualSourcePortRef.srcPort{end+1}=[src_blk_o.Parent];
                                                    actualSourcePortRef.srcPortNum{end+1}=str2double(graph_blk_o.Port);
                                                end
                                            else

                                                actualSourcePortRef.port{end+1}=[outPort{j}.Parent,':',num2str(outPort{j}.PortNumber)];
                                                actualSourcePortRef.srcPort{end+1}=[src_port.Parent];
                                                actualSourcePortRef.srcPortNum{end+1}=src_port.PortNumber;
                                            end
                                        end
                                    else
                                        if isStatechart






                                        else
                                            trueSrcPorts{end+1}=outPort{j};
                                        end
                                    end
                                end

                            end

                        end
                    catch ME
                        disp(ME.message);
                    end

                end




                for i=1:length(internalRefToExternalSourcePort.srcPort)
                    match=find(strcmp(actualSourcePortRef.srcPort,[internalRefToExternalSourcePort.srcPort{i}]));

                    for j=1:length(match)
                        if actualSourcePortRef.srcPortNum{match(j)}==internalRefToExternalSourcePort.srcPortNum{i}
                            actualSourcePortRef.srcPort{match(j)}=internalRefToExternalSourcePort.intSrcPort{i};
                            actualSourcePortRef.srcPortNum{match(j)}=internalRefToExternalSourcePort.intSrcPortNum{i};
                        end
                    end
                end



                allSrcPorts_v=unique([allSrcPorts{:}]);
                if isempty(allSrcPorts_v)
                    return
                end

                allSrcPorts={allSrcPorts_v(:)};

                trueSrcPorts_v=unique([trueSrcPorts{:}]);
                if~isempty(trueSrcPorts_v)
                    trueSrcPorts={trueSrcPorts_v(:)};
                end

                loggedSrcPorts_v=find(allSrcPorts_v,'DataLogging','on');






                trueSrcPorts_ofLoggedPorts_v=[];
                for i=1:length(loggedSrcPorts_v)
                    match=find(strcmp(actualSourcePortRef.port,[loggedSrcPorts_v(i).Parent,':',num2str(loggedSrcPorts_v(i).PortNumber)]));

                    if isempty(match)

                        if i==1
                            trueSrcPorts_ofLoggedPorts_v=loggedSrcPorts_v(i);
                        else
                            trueSrcPorts_ofLoggedPorts_v(i)=loggedSrcPorts_v(i);
                        end
                    else
                        blk_o=get_param(actualSourcePortRef.srcPort{match},'object');
                        [outPortD,isStatechart]=loc_getPort(blk_o);
                        if length(outPortD)<2
                            if actualSourcePortRef.srcPortNum{match}~=1

                                break;
                            end
                            if i==1
                                trueSrcPorts_ofLoggedPorts_v=outPortD;
                            else
                                trueSrcPorts_ofLoggedPorts_v(i)=outPortD;
                            end
                        else

                            if i==1
                                trueSrcPorts_ofLoggedPorts_v=outPortD{actualSourcePortRef.srcPortNum{match}};
                            else
                                trueSrcPorts_ofLoggedPorts_v(i)=outPortD{actualSourcePortRef.srcPortNum{match}};
                            end
                        end
                    end

                end





                [unique_trueSrcPorts_ofLoggedPorts_v,idx_unique,idx_redundant]=unique(trueSrcPorts_ofLoggedPorts_v);



                if length(unique_trueSrcPorts_ofLoggedPorts_v)<length(trueSrcPorts_ofLoggedPorts_v)






                    for i=1:length(idx_redundant)

                        match=find(idx_redundant==i);

                        if length(match)>1

                            tmp_port_list={};
                            for j=1:length(match)
                                tmp_port_list{end+1}=loggedSrcPorts_v(match(j));
                            end
                            redundantLoggingPorts{end+1}=tmp_port_list;
                        end
                    end

                end



                trueSrcPorts_not_logged_v=setdiff(trueSrcPorts_v,unique_trueSrcPorts_ofLoggedPorts_v);
                for i=1:length(trueSrcPorts_not_logged_v)
                    trueSrcPorts_not_logged{end+1}=trueSrcPorts_not_logged_v(i);
                end




                function[skip_srcPort,skipType]=utilCheckDestinationPorts(port_s)






                    skip_srcPort=false;
                    skipType='';

                    if port_s.Line==-1
                        skip_srcPort=true;
                        return
                    end

                    try

                        seg=get_param(port_s.Line,'object');

                        DstPortH=seg.DstPortHandle;

                        rIdx=find(DstPortH>-1);
                        if~isempty(rIdx)

                            port_d=get_param(DstPortH(rIdx),'object');
                        end

                        if~iscell(port_d)
                            tmp=port_d;
                            clear port_d;
                            port_d{1}=tmp;
                        end
                        for j=1:length(port_d)
                            if strcmp(port_d{j}.CompiledPortDataType,'fcn_call')
                                skip_srcPort=true;
                                skipType='fcn_call';
                                break;
                            end
                            if strcmp(port_d{j}.CompiledPortDataType,'action')
                                skip_srcPort=true;
                                skipType='action';
                                break;
                            end

                            ls=get_param(port_d{j}.Line,'object');
                            dstBlk=get_param(ls.DstBlockHandle,'object');
                            if isa(dstBlk,'Simulink.Merge')
                                skip_srcPort=true;
                                skipType='merge';
                                break;
                            elseif isa(dstBlk.getParent,'Simulink.SubSystem')&&isa(dstBlk,'Simulink.Outport')

                                dstH=dstBlk.getActualDst;
                                rIdx=find(dstH>1);
                                if~isempty(rIdx)
                                    for kk=1:length(rIdx)
                                        try
                                            do=get_param(dstH(rIdx(kk)),'object');
                                        catch

                                            continue
                                        end
                                        if do.Line~=-1
                                            lo=get_param(do.Line,'object');
                                            dBlkH=lo.DstBlockHandle;
                                            rIdx1=find(dBlkH>-1);
                                            if~isempty(rIdx1)

                                                dblk_o=get_param(dBlkH(rIdx1),'object');
                                                if isa(dblk_o,'Simulink.Merge')
                                                    skip_srcPort=true;
                                                    skipType='merge';
                                                    break;
                                                end
                                            end
                                        end
                                    end
                                end

                            end
                        end

                    catch

                        skip_srcPort=true;
                    end





















































