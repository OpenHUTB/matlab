function removeRootInportsIfNeeded(sliceXfrmr,mdl,mdlCopy,option)





    if(~option.SliceOptions.RootLevelInterfaces)
        removeUnusedIO=true;
    else


        fcnCallInports=find_system(mdl,'SearchDepth',1,...
        'BlockType','Inport',...
        'OutputFunctionCall','on');
        removeUnusedIO=~isempty(fcnCallInports);
    end

    if removeUnusedIO
        removeUnreachableRootLevelOutport(sliceXfrmr,mdlCopy);
        removeUnreachableRootLevelInports(sliceXfrmr,mdlCopy);
    end
end



function removeUnreachableRootLevelOutport(sliceXfrmr,mdl)

    bd=get_param(mdl,'Object');
    children=bd.getChildren;
    outports=children(arrayfun(@(x)isa(x,'Simulink.Outport'),children));
    unreachable=outports(arrayfun(@isOutportDisconnected,outports));
    bH=arrayfun(@(x)x.Handle,unreachable);
    for i=1:length(bH)
        sliceXfrmr.deleteBlock(bH(i));
    end
end


function removeUnreachableRootLevelInports(sliceXfrmr,mdl)

    bd=get_param(mdl,'Object');
    children=bd.getChildren;
    outports=children(arrayfun(@(x)isa(x,'Simulink.Inport'),children));
    unreachable=outports(arrayfun(@isInportDisconnected,outports));
    bH=arrayfun(@(x)x.Handle,unreachable);
    for i=1:length(bH)
        sliceXfrmr.deleteBlock(bH(i));
    end
end

function yesno=isOutportDisconnected(outportB)
    yesno=get(outportB.PortHandles.Inport,'Line')<0;
end

function yesno=isInportDisconnected(inportB)
    yesno=get(inportB.PortHandles.Outport,'Line')<0;
end
