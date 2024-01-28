function json=getShortestPath(artUUID,unitUUID)

    cprj=currentProject;
    as=alm.internal.ArtifactService.get(cprj.RootFolder);
    g=as.getGraph();
    startVertex=g.getArtifactByUuid(unitUUID);
    target=g.getArtifactByUuid(artUUID);
    FileToAdd=[];

    if~belongsToUnit(target,unitUUID)
        kids=g.getAllContained(target);
        for i=1:numel(kids)
            if belongsToUnit(kids(i),unitUUID)
                FileToAdd=target;
                target=kids(i);
                break;
            end
        end
    end
    q_harness=alm.gdb.Query("QUALITY_METRICS","TRAVERSE_DesignToHarness");
    q_harness.setParam("StartPointUuid",unitUUID);
    qr_harness=q_harness.execute(g);

    q_design=alm.gdb.Query("QUALITY_METRICS","TRAVERSE_UnitDesign");
    q_design.setParam("StartPointUuid",unitUUID);
    qr_design=q_design.execute(g);
    q_up=alm.gdb.Query("QUALITY_METRICS","TRAVERSE_UnitUpstreamAssociations");
    q_up.setParam("StartPointUuid",unitUUID);
    qr_up=q_up.execute(g);
    q_down=alm.gdb.Query("QUALITY_METRICS","TRAVERSE_UnitDownstreamAssociations");
    q_down.setParam("StartPointUuid",unitUUID);
    qr_down=q_down.execute(g);

    cons=[qr_design.getConnections,...
    qr_up.getConnections(),...
    qr_down.getConnections(),...
    qr_harness.getConnections()];
    pth=findPathBreadthFirst(target,startVertex,cons);

    if isa(pth,'alm.Artifact')
        mf0=mf.zero.Model;
        diag=diagram.editor.model.Diagram(mf0);
        createEntity(mf0,pth,diag);
    else
        [mf0,diag]=createDiagramFromPath(pth);
    end

    if~isempty(FileToAdd)
        if isa(pth,'alm.Artifact')
            src=diag.entities(1);
            dst=createEntity(mf0,FileToAdd,diag);
        else
            src=diag.entities(end);
            dst=createEntity(mf0,FileToAdd,diag);
        end
        createConnection(mf0,getString(message('dashboard:trace:CONTAINS')),src,dst,false,diag);
    end

    s=mf.zero.io.JSONSerializer;
    json=s.serializeToString(mf0);
    json=['{"diagram":',json,'}'];

end


function out=belongsToUnit(art,unitUUID)
    units=art.SharedData.getByKey('unit');
    out=~isempty(findobj(units,'Value',unitUUID));
end


function[mf0,diag]=createDiagramFromPath(pth)
    mf0=mf.zero.Model;
    diag=diagram.editor.model.Diagram(mf0);
    i=1;
    while i<=numel(pth)
        if i==1
            leftItem=createEntity(mf0,pth(1).getLeftItem,diag);
        else
            leftItem=diag.entities(end);
        end

        if strcmp(pth(i).getRightItem.Type,'sl_req_link')
            rightItem=createEntity(mf0,pth(i+1).getRightItem,diag);
            skip=1;
        else
            rightItem=createEntity(mf0,pth(i).getRightItem,diag);
            skip=0;
        end
        createConnection(mf0,pth(i).getRelationship,leftItem,rightItem,pth(i).isLeftItemSource,diag);
        i=i+1+skip;
    end
end


function pth=findPathBreadthFirst(startVertex,target,connections)

    pth=startVertex;

    if startVertex==target
        return
    end

    q={{startVertex,[],connections}};
    visitedNodes=[];
    while~isempty(q)

        ElementToCheck=q{1};
        q=q(2:end);
        srces=arrayfun(@getRightItem,ElementToCheck{3});

        idx=ElementToCheck{1}==srces;
        kidsCon=ElementToCheck{3}(idx);

        kids=arrayfun(@getLeftItem,kidsCon);
        for i=1:numel(kids)
            if~isempty(visitedNodes)&&(any(visitedNodes==kids(i)))
                continue;
            end
            visitedNodes=[visitedNodes,kids(i)];%#ok<AGROW>

            if kids(i)==target
                pth=fliplr([ElementToCheck{2},kidsCon(i)]);
                return
            else
                q=[q,{{kids(i),[ElementToCheck{2},kidsCon(i)],ElementToCheck{3}(~idx)}}];%#ok<AGROW>
            end
        end
    end
end


function con=createConnection(mf0,relationship,leftItem,rightItem,isLeftSrc,diag)
    con=diagram.editor.model.Connection(mf0);
    con.type='dependencyedge';
    if isa(relationship,'alm.Relationship')
        con.title=getString(message(sprintf('dashboard:trace:%s',relationship.Type)));
    else
        con.title=char(relationship);
    end
    if isLeftSrc
        outprt=findobj(leftItem.ports.toArray,'type','DependencyOutPort','location',diagram.editor.model.Location.Bottom);
        if isempty(outprt)
            outprt=createPort(mf0,leftItem,'DependencyOutPort',diagram.editor.model.Location.Bottom);
        end
        con.srcElement=outprt;
        inprt=findobj(rightItem.ports.toArray,'type','DependencyInPort','location',diagram.editor.model.Location.Top);
        if isempty(inprt)
            inprt=createPort(mf0,rightItem,'DependencyInPort',diagram.editor.model.Location.Top);
        end
        con.dstElement=inprt;
    else
        inprt=findobj(leftItem.ports.toArray,'type','DependencyInPort','location',diagram.editor.model.Location.Bottom);
        if isempty(inprt)
            inprt=createPort(mf0,leftItem,'DependencyInPort',diagram.editor.model.Location.Bottom);
        end
        con.dstElement=inprt;
        outprt=findobj(rightItem.ports.toArray,'type','DependencyOutPort','location',diagram.editor.model.Location.Top);
        if isempty(outprt)
            outprt=createPort(mf0,rightItem,'DependencyOutPort',diagram.editor.model.Location.Top);
        end
        con.srcElement=outprt;
    end
    con.parent=diag;
end


function prt=createPort(mf0,parent,type,loc)
    prt=diagram.editor.model.Port(mf0);
    prt.type=type;
    prt.parent=parent;
    prt.shape='circle';
    prt.location=loc;
    if strcmp(type,'DependencyOutPort')
        prt.size=createPortSize(9);
    else
        prt.size=createPortSize(0);
    end
end


function ent=createEntity(mf0,art,diag)
    ent=diagram.editor.model.Entity(mf0);
    ent.size=createEntitySize();
    ent.type='dependencyvertex';
    if~isempty(art.Label)
        ent.title=art.Label;
    else
        ent.title=[art.getSelfContainedArtifact().Label,':',art.Address];
    end
    ent.attributes=mf.zero.meta.AttributeMap(mf0);
    if art.isFile()
        [~,fn,ext]=fileparts(art.Address);
        clr='';
        switch ext
        case{'.slreqx','.slmx'}
            clr='COLOR_5';
        case{'.slx'}
            clr='COLOR_2';
        case{'.mldatx'}
            clr='COLOR_DEFAULT';
        case{'.sldd'}
            clr='COLOR_3';
        end
        ent.attributes.insert(createStringAttribute(mf0,'color',clr));
        ent.attributes.insert(createStringAttribute(mf0,'extension',ext));
        ent.attributes.insert(createStringAttribute(mf0,'stem',fn));
        ent.attributes.insert(createStringAttribute(mf0,'inFile',''));
    else
        switch art.Type        case{'sl_block_diagram','sl_ref','sl_subsystem','sl_model_reference',...
            'sf_chart','sl_embedded_matlab_fcn','sf_truth_table','sf_graphical_fcn',...
            'sf_state_transition_chart','sf_group','sf_state','sl_matlab_ref','sl_subsystem_reference'}
            ent.attributes.insert(createStringAttribute(mf0,'color','COLOR_SIMULINK_ARTIFACTS'));

        case{'sl_test_file_element','sl_test_suite','sl_test_case','sl_test_iteration','sl_test_case_result','sl_test_resultset'}
            ent.attributes.insert(createStringAttribute(mf0,'color','COLOR_TEST_ARTIFACTS'));

        case{'sl_req','sl_req_info','sl_req_container','sl_req_link'}
            ent.attributes.insert(createStringAttribute(mf0,'color','COLOR_REQUIREMENT_ARTIFACTS'));
        end
        ent.attributes.insert(createStringAttribute(mf0,'extension',''));
        ent.attributes.insert(createStringAttribute(mf0,'stem',ent.title));
        if art.getSelfContainedArtifact().isFile()
            ent.attributes.insert(createStringAttribute(mf0,'inFile',art.getSelfContainedArtifact().Label));
        else
            ent.attributes.insert(createStringAttribute(mf0,'inFile',''));
        end
    end
    ent.attributes.insert(createStringAttribute(mf0,'type',art.Type));
    ent.parent=diag;
end


function sa=createStringAttribute(mf0,key,value)
    sa=mf.zero.meta.StringAttribute(mf0);
    sa.key=key;
    sa.value=value;
end


function sz=createEntitySize()
    sz=diagram.geometry.Rect();
    sz.right=100;
    sz.bottom=100;

    sz.width=185;
    sz.height=32;
end


function sz=createPortSize(wh)
    sz=diagram.geometry.Rect();
    sz.right=0;
    sz.bottom=0;
    sz.width=wh;
    sz.height=wh;
end
