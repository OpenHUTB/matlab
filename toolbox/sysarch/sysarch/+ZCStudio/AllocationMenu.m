function schema=AllocationMenu(~)






    schema=sl_container_schema;
    schema.tag='SystemComposer:AllocationMenu';
    schema.label=DAStudio.message('SystemArchitecture:studio:Allocations');
    schema.generateFcn=@(cbinfo)generateSubmenu(cbinfo);

end


function children=generateSubmenu(~)
    children={...
    {@generateSelectAsSource,[]},...
    {@generateSelectAsTarget,[]},...
    {@generateSelectAsTargetAndScenario,[]}...
    };
end


function schema=generateSelectAsSource(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('SystemArchitecture:studio:SelectAsAllocSource');
    schema.state='Enabled';
    schema.tag='SystemComposer:AllocationSubmenu:SelectAsAllocSource';
    elem=getSelectedElements(cbinfo);
    schema.callback=@(x,y)selectAsSourceCB(elem);
    if length(elem)>1||~isElemAllocatable(elem)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
end


function schema=generateSelectAsTarget(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('SystemArchitecture:studio:SelectAsAllocTarget');
    schema.state='Enabled';
    schema.tag='SystemComposer:AllocationSubmenu:SelectAsAllocTarget';
    elem=getSelectedElements(cbinfo);
    schema.callback=@(~)selectAsTargetCB(elem);

    if systemcomposer.allocation.internal.ContextMenuAllocator.hasSource()&&isscalar(elem)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
end


function schema=generateSelectAsTargetAndScenario(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.label=DAStudio.message('SystemArchitecture:studio:SelectAsAllocTargetInNewScenario');
    schema.state='Enabled';
    schema.tag='SystemComposer:AllocationSubmenu:SelectAsTargetInNewScenario';
    elem=getSelectedElements(cbinfo);
    schema.callback=@(~)selectAsTargetInNewScenarioCB(elem);

    if systemcomposer.allocation.internal.ContextMenuAllocator.hasSource()&&isscalar(elem)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
end


function selectAsSourceCB(elem)
    systemcomposer.allocation.internal.ContextMenuAllocator.selectForAllocation(elem);
end


function selectAsTargetCB(elem)
    systemcomposer.allocation.internal.ContextMenuAllocator.allocateTo(elem);
end


function selectAsTargetInNewScenarioCB(elem)
    useCurrentScenario=false;
    systemcomposer.allocation.internal.ContextMenuAllocator.allocateTo(elem,useCurrentScenario);
end


function elems=getSelectedElements(cbinfo)

    compPrts=SLStudio.Utils.getSelectedPorts(cbinfo);
    compPrts(compPrts==-1)=[];


    blks=SLStudio.Utils.getSelectedBlockHandles(cbinfo);


    segs=SLStudio.Utils.getSelectedSegmentHandles(cbinfo);
    if numel(segs)>1
        segsChildren=get_param(segs,'LineChildren');
        idxValidZcConn=cellfun(@isempty,segsChildren);
        segs=segs(idxValidZcConn);
    end

    selectHdls=horzcat(blks,compPrts,segs);

    if isempty(selectHdls)

        hdlCurrentElem=SLStudio.Utils.getDiagramHandle(cbinfo);
        elems=systemcomposer.utils.getArchitecturePeer(hdlCurrentElem);
    else
        elems=[];
        for hdl=selectHdls
            elems=[elems,systemcomposer.utils.getArchitecturePeer(hdl)];%#ok<AGROW>
        end

    end
end


function is=isElemAllocatable(elem)


    is=isa(elem,'systemcomposer.architecture.model.design.BaseComponent')||...
    isa(elem,'systemcomposer.architecture.model.design.ComponentPort')||...
    isa(elem,'systemcomposer.architecture.model.design.BaseConnector')||...
    isRootArchitecture(elem)||...
    isRootArchitecturePort(elem);

    function is=isRootArchitecture(elem)
        is=isa(elem,'systemcomposer.architecture.model.design.Architecture')&&...
        (elem==elem.getTopLevelArchitecture());
    end

    function is=isRootArchitecturePort(elem)
        is=isa(elem,'systemcomposer.architecture.model.design.ArchitecturePort')&&...
        isRootArchitecture(elem.getArchitecture());
    end
end
