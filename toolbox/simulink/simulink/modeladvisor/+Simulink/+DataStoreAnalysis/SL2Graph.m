




classdef SL2Graph<handle

    properties

graph
    end

    properties

leafblks
CECTree
SortedLists
    end




    properties(Access=private)
queue
    end
    methods(Access=private)


        function enqueue(obj,idx)
            if~any(obj.queue==idx)
                obj.queue=[obj.queue,idx];
            end
        end

        function idx=dequeue(obj)
            idx=obj.queue(1);
            obj.queue=obj.queue(2:end);
        end
    end





    methods(Access=private)
        function[node,ind,isnew]=add_node(obj,nodetype,nodename,...
            nodeid,nodehandle)








            newnode=Simulink.DataStoreAnalysis.ENode(nodetype,nodename,nodeid,nodehandle);
            [ind,isnew]=obj.graph.add_node(newnode);
            node=obj.graph.nodes(ind);
        end

        function[edge,ind,isnew]=add_edge(obj,edgetype,edgehandle,...
            src,dst)




            newedge=Simulink.DataStoreAnalysis.EEdge(edgetype,edgehandle,src,dst);
            [ind,isnew]=obj.graph.add_edge(newedge);
            edge=obj.graph.edges(ind);
        end
    end




    methods(Access=private)

        function[name,id,handle]=trace_to_context(obj,node)

            h=node.handle;
            id=get_CECid(obj,h);

            if(id>0)
                name=get_full_name(obj.CECTree(id).cecHandle);
                handle=obj.CECTree(id).cecHandle;
            else
                name=get_param(bdroot(h),'Name');
                handle=get_param(bdroot(h),'Handle');
            end
        end

        function id=get_CECid(obj,handle)




            id=0;
            for g_c_i=1:length(obj.SortedLists)
                if any(obj.SortedLists(g_c_i).SortedList==handle)
                    id=g_c_i;
                    break;
                end
            end
        end


        function[name,handle]=trace_dep_to_block(obj,node)


            bh=node.handle;
            bO=get(bh,'Object');
            handle=[];
            name='';
            if bO.isSynthesized
                return;
            end
            rto=get_param(bh,'RuntimeObject');
            ph=get(bh,'PortHandles');
            iph=ph.Inport;

            for tdtci=1:length(iph)
                inport=rto.InputPort(tdtci);
                if isempty(iph)
                    continue;
                end
                if strcmpi(node.node_type,'context')||...
                    inport.DirectFeedthrough


                    ipo=get(iph(tdtci),'Object');
                    actualSrcs=ipo.getBoundedSrc;
                    for tci=1:size(actualSrcs,1)
                        porthandle=actualSrcs(tci,1);
                        blockhandle=get(porthandle,'ParentHandle');
                        if strcmpi(get(blockhandle,'BlockType'),'Inport')




                            continue;
                        end
                        newhandles=blockhandle;
                        handle=[handle;newhandles];
                    end
                end
            end
            name=get_full_name(handle);
        end


        function[name,handle,combine,port_handle]=...
            trace_to_controller(obj,node)







            subsys_hd=node.handle;
            [handle,combine,port_handle]=get_CECcontroller(subsys_hd);
            [handle,port_handle]=trace_through_hiddenbuf(handle,port_handle);
            if~isempty(combine)&&strcmp(combine.type,'enabled_and_triggered')
                [combine.enabled,combine.enabled_port]=...
                trace_through_hiddenbuf(combine.enabled,combine.enabled_port);
                [combine.triggered,combine.triggered_port]=...
                trace_through_hiddenbuf(combine.triggered,combine.triggered_port);
            end

            name=get_full_name(handle);
        end

    end




    methods(Access=private)

        function handle_actual_srcs(obj,mynode)

            [name,handle]=obj.trace_dep_to_block(mynode);
            if size(handle,1)>1
                for hasi=1:size(handle,1)
                    handle_actual_src(obj,mynode,...
                    name{hasi},[],handle(hasi));
                end
            elseif~isempty(handle)
                handle_actual_src(obj,mynode,name,[],handle)
            end
        end

        function handle_actual_src(obj,current_node,name,id,handle)
            if any([obj.CECTree.cecHandle]==handle)
                [actual_src_node,idx,isnew]=...
                obj.add_node('context',name,id,handle);
            else
                [actual_src_node,idx,isnew]=...
                obj.add_node('regular',name,id,handle);
            end

            obj.add_edge('dependency',-2,actual_src_node,current_node);

            if isnew

                obj.enqueue(actual_src_node);
            end
        end


        function TF=handle_controllers(obj,mynode)


            [name,handle,combine,port_handle]=...
            obj.trace_to_controller(mynode);
            TF=~isempty(handle);
            if size(handle,1)>1
                for b_g_i=1:size(handle,1)
                    [newnode,dummy,isnew]=obj.add_node(...
                    'regular',name{b_g_i},[],handle(b_g_i));

                    obj.add_edge('control',port_handle(b_g_i,:),...
                    newnode,mynode);

                    mynode.combine=combine;
                    if isnew
                        obj.enqueue(newnode);
                    end
                end
            elseif~isempty(handle)
                [newnode,dst,isnew]=obj.add_node('regular',...
                name,[],handle);
                obj.add_edge('control',port_handle,newnode,mynode);
                mynode.combine=combine;
                if isnew
                    obj.enqueue(newnode);
                end
            end
        end


        function handle_parent(obj,mynode)

            [name,id,handle]=...
            obj.trace_to_context(mynode);
            [node,dst,isnew]=obj.add_node(...
            'context',name,id,handle);
            obj.add_edge('parent',-1,node,mynode);

            if(id~=0)&&isnew
                obj.enqueue(node);
            end

        end

    end

    methods(Access=public)



        function obj=SL2Graph(mdlname,leafblks)

            if~strcmp(get_param(mdlname,'SimulationStatus'),'paused')
                error('CreateGraph:ModelNotCompiled',...
                'The given model is not compiled');
            end

            if~all(ishandle(leafblks))
                error('CreateGraph:InputMustBeHandles',...
                'Input must be valid Simulink handles.');
            end
            [obj.CECTree,obj.SortedLists]=get_compiledInfo(mdlname);


            obj.leafblks=leafblks;
            obj.graph=Simulink.DataStoreAnalysis.EGraph;
        end



        function build_graph(obj)

            obj.queue=[];
            for bgi=1:size(obj.leafblks,1)
                bh=obj.leafblks(bgi,1);
                bn=get_full_name(bh);





                node=obj.add_node('leaf',bn,[],bh);




                obj.handle_parent(node);
                obj.handle_actual_srcs(node);

                while~isempty(obj.queue)
                    node=obj.dequeue();

                    if node.node_id==0
                        continue;
                    end
                    switch node.node_type
                    case 'context'
                        obj.handle_controllers(node);
                        obj.handle_parent(node);
                        obj.handle_actual_srcs(node);

                    case 'regular'
                        obj.handle_actual_srcs(node);
                        obj.handle_parent(node);
                    end
                end
            end

        end
    end
end

function[CECTree,SortedLists]=get_compiledInfo(mdlname)




    rootsys=get_param(mdlname,'Object');
    blist=rootsys.getSortedList;

    queue=[];

    SortedLists=struct('SortedList',{});
    CECTree=struct('cecHandle',{});

    for i=1:length(blist)
        if strcmpi(get(blist(i),'BlockType'),'Subsystem')
            enqueue(blist(i));
        end
    end

    while~isempty(queue)
        h=dequeue();
        blist=get_param(h,'SortedList');
        CECTree(end+1)=struct('cecHandle',h);
        SortedLists(end+1)=struct('SortedList',blist);
        for i=1:length(blist)
            if strcmpi(get(blist(i),'BlockType'),'Subsystem')
                enqueue(blist(i));
            end
        end
    end


    function enqueue(h)
        if~any(queue==h)
            queue=[queue,h];
        end
    end

    function h=dequeue()
        h=queue(1);
        queue=queue(2:end);
    end

end
function name=get_full_name(handle)

    path=get(handle,'Path');
    name=get_param(handle,'Name');
    if iscell(name)
        seps=cellstr(repmat('/',size(name,1),1));
    else
        seps='/';
    end
    name=strcat(path,strcat(seps,name));
end

function[newhandles,newport_handles]=...
    trace_through_hiddenbuf(oldhandles,oldport_handles)


    newhandles=[];
    newport_handles=[];
    for i=1:length(oldhandles)
        walkHandle=oldhandles(i);
        walkObj=get(walkHandle,'Object');
        synthesized=walkObj.isSynthesized;
        type=get(walkHandle,'BlockType');
        if synthesized&&strcmpi(type,'SignalConversion')

            porthandles=get(walkHandle,'PortHandles');

            inPort=get(porthandles.Inport,'Object');
            outporthandles=inPort.getActualSrc;
            srcnames=get(outporthandles(:,1),'Parent');
            if~iscell(srcnames)
                newhandles=[newhandles;get(outporthandles(:,1),...
                'ParentHandle')];
                newport_handles=[newport_handles;outporthandles];
            else
                for j=1:length(srcnames)
                    newhandles=[newhandles;get(outporthandles(j,1),...
                    'ParentHandle')];
                    newport_handles=[newport_handles;outporthandles(j,:)];
                end
            end
        else
            newhandles=[newhandles;oldhandles(i)];
            newport_handles=[newport_handles;oldport_handles(i,:)];
        end
    end
end

function[hd,combine,port_handle]=get_CECcontroller(subsys_hd)





    subsys=get(subsys_hd,'Object');
    hd=[];
    combine=struct('type','');
    port_handle=[];
    if(subsys.PortHandles.Ifaction)
        if_port=get(subsys.PortHandles.Ifaction,'Object');
        out_port=if_port.getActualSrc;
        port_handle=[port_handle;out_port];
        hd=[hd;get(out_port(1),'ParentHandle')];
        combine.type='action';
    end

    hd_trig=[];
    trig_port_handle=[];
    if(subsys.PortHandles.Trigger)
        trigger_port=get(subsys.PortHandles.Trigger,'Object');
        out_port=trigger_port.getActualSrc;
        for i=1:size(out_port,1)
            hd_trig(i,1)=get(out_port(i,1),'ParentHandle');
            trig_port_handle(i,:)=out_port(i,:);
        end
        hd=[hd;hd_trig];
        port_handle=[port_handle;trig_port_handle];
        triggered=hd;
        if strcmp(get(subsys.PortHandles.Trigger,'CompiledPortDataType'),...
            'fcn_call')
            combine.type='fcn_call';
        end
    else
        triggered=[];
    end

    hd_enable=[];
    enable_port_handle=[];
    if(subsys.PortHandles.Enable)
        enable_port=get(subsys.PortHandles.Enable,'Object');
        out_port=enable_port.getActualSrc;
        for i=1:size(out_port,1)
            hd_enable(i,1)=get(out_port(i,1),'ParentHandle');
            enable_port_handle(i,:)=out_port(i,:);
        end
        hd=[hd;hd_enable];
        port_handle=[port_handle;enable_port_handle];
        enabled=hd_enable;
    else
        enabled=[];
    end

    if~isempty(triggered)&&~isempty(enabled)
        combine.type='enabled_and_triggered';
        combine.triggered=triggered;
        combine.triggered_port=trig_port_handle;
        combine.enabled=enabled;
        combine.enabled_port=enable_port_handle;
    end
end

