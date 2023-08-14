function traceResult=traceBlock(type,blkHandle)







    allPorts=get_param(blkHandle,'PortHandles');
    blkType=get_param(blkHandle,'BlockType');

    if strcmpi(type,'dst')

        propName='NonVirtualDstPorts';
        if any(strcmp({'Outport','Goto'},blkType))
            portH=allPorts.Inport;



        else
            portH=allPorts.Outport;
        end
    else

        propName='NonVirtualSrcPorts';
        if any(strcmp({'Inport','From'},blkType))
            portH=allPorts.Outport;
        else
            portH=allPorts.Inport;
        end
    end

    if isempty(portH)
        traceResult={};
        return;
    end

    virtualBlockTypes={'From','Goto','Inport','Outport'};
    for i=length(portH):-1:1
        tracedBlocks={getString(message('RptgenSL:rptgen_sl:unconnectedMsg'))};
        lineH=get_param(portH(i),'Line');
        if ishandle(lineH)
            tracedPort=rptgen.safeGet(lineH,propName,'get_param');tracedPort=tracedPort{1};
            if ishandle(tracedPort)
                tracedBlocks=rptgen.safeGet(tracedPort,'Parent','get_param');
                bType=rptgen.safeGet(tracedBlocks,'BlockType','get_param');
                for j=1:length(bType)
                    if strcmp(bType{j},'N/A')
                        tracedBlocks{j}=getString(message('RptgenSL:rptgen_sl:unconnectedMsg'));
                    elseif any(strcmp(virtualBlockTypes,bType{j}))
                        tracedBlocks{j}=[];
                    end



                end
            end
        end
        traceResult{i,1}=tracedBlocks;
    end

