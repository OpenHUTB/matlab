function h=getSlSfHandle(in)


















    if(ischar(in)||isstring(in))
        h=resolveFromChar(in);

    elseif isempty(in)
        h=in;

    elseif isa(in,'double')
        h=resolveFromDouble(in);

    elseif isa(in,'Simulink.Line')
        h=in;

    elseif isa(in,'Simulink.Object')
        h=in.Handle;

    elseif isa(in,'Stateflow.Object')
        h=in;

    elseif isa(in,'GLUE2.DiagramElement')
        h=resolveFromGLUE2DiagramElement(in);

    elseif isa(in,'GLUE2.HierarchyId')
        h=resolveHierarchyId(in);

    elseif isa(in,'mlreportgen.finder.Result')
        h=slreportgen.utils.getSlSfHandle(in.Object);

    else
        error(message('slreportgen:utils:error:unexpectedType',class(in)));
    end
end

function out=resolveHierarchyId(in)
    hs=GLUE2.HierarchyService;
    switch hs.getDomainName(in)
    case 'Simulink'
        slhsu=SLM3I.HierarchyServiceUtils;
        out=slhsu.getHandle(in);

    case 'Stateflow'
        sfhs=StateflowDI.HierarchyServiceUtils;
        id=sfhs.getObjectId(in);
        r=slroot();
        out=idToHandle(r,double(id));

    case 'StudioAdapterDomain'
        ehid=hs.getParent(in);
        out=resolveHierarchyId(ehid);

    otherwise
        m3iobj=hs.getM3IObject(in);
        if isempty(m3iobj.temporaryObject)

            error(message("slreportgen:utils:error:noObjectBackingHID"));
        end
        out=resolveFromGLUE2DiagramElement(m3iobj.temporaryObject);
    end
end

function out=resolveFromGLUE2DiagramElement(in)
    switch class(in)
    case 'SLM3I.Diagram'
        out=get_param(in.getFullName(),'Handle');

    case{'SLM3I.Block','SLM3I.Annotation'}
        out=in.handle;

    case{'StateflowDI.Subviewer','StateflowDI.State','StateflowDI.Transition'}
        r=slroot();
        out=r.idToHandle(double(in.backendId));

    case 'SLM3I.Line'

        seg=get_param(in.segment.at(1).handle,'Object');
        out=getLine(seg);

    case 'SA_M3I.StudioAdapterDiagram'
        if(in.stateflowId>0)
            r=slroot();
            out=r.idToHandle(double(in.stateflowId));
        else
            out=in.blockHandle;
        end

    otherwise
        error(message('slreportgen:utils:error:unexpectedType',class(in)));
    end
end

function out=resolveFromDouble(in)
    r=slroot();
    if isValidSlObject(r,in)
        out=in;
    else
        out=idToHandle(r,in);
        if isempty(out)
            error(message('slreportgen:utils:error:invalidDoubleHandle'));
        end
    end
end

function out=resolveFromChar(in)
    try
        out=get_param(in,'Handle');
    catch me
        if~isempty(regexp(in,':\d+$','once'))
            out=Simulink.ID.getHandle(in);
        else
            rethrow(me);
        end
    end
end
