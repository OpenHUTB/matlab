




classdef Graph2SAT<handle






    properties

graph
    end
    properties

nNodes
nEdges
    end

    methods
        function obj=Graph2SAT(g)

            obj.graph=g;

            obj.nNodes=numel(g.nodes);
            obj.nEdges=numel(g.edges);
        end
    end

    methods(Access=private)








        function idx=get_edge_ready(obj,edges)
            idx=[];
            for j=1:length(edges)
                edge=edges(j);
                i=obj.graph.find_edge(edge);
                idx=[idx,2*obj.nNodes+2*i-1];
            end
        end


        function idx=get_edge_activation(obj,edges)

            idx=[];
            for j=1:length(edges)
                edge=edges(j);
                i=obj.graph.find_edge(edge);
                idx=[idx,2*obj.nNodes+2*i];
            end
        end


        function idx=get_start_node(obj,node)
            i=obj.graph.find_node(node);
            idx=2*i-1;
        end


        function idx=get_end_node(obj,node)
            i=obj.graph.find_node(node);
            idx=2*i;
        end



        function clause=empty_clause(obj)
            clause=sparse(1,2*obj.nNodes+2*obj.nEdges);
        end



        function yesno=equal_signal(obj,s1,s2)

            yesno=strcmpi(s1.edge_type,'control')&&...
            strcmpi(s2.edge_type,'control')&&...
            all(s1.handle==s2.handle);
        end



        function dstIdx=get_idx(obj,hdl)



            allhdl=zeros(1,length(obj.nodelist));
            for tmpI=1:length(obj.nodelist)
                allhdl(tmpI)=obj.nodelist(tmpI).handle;
            end


            dstIdx=-ones(size(hdl));
            for hdlIdx=1:length(hdl)
                dstIdx(hdlIdx)=find(allhdl==hdl(hdlIdx));
            end
        end
    end

    methods(Access=private)









        function preds=one_active_child(obj,childEdges)
            preds=[];
            if isempty(childEdges)
                return;
            end

            for i=1:length(childEdges)
                if i==1
                    childNodes=childEdges(i).sink;
                else
                    childNodes=[childNodes,childEdges(i).sink];
                end
            end

            ChildBList=reshape(childNodes,1,numel(childNodes));

            for childIdx=1:length(ChildBList)
                child1=ChildBList(childIdx);
                for childIdx2=childIdx+1:length(ChildBList)
                    child2=ChildBList(childIdx2);
                    clause=obj.empty_clause();
                    clause(obj.get_start_node(child1))=-1;
                    clause(obj.get_start_node(child2))=-1;
                    clause(obj.get_end_node(child1))=1;
                    clause(obj.get_end_node(child2))=1;
                    preds=[preds;clause];
                end
            end
        end





        function preds=block_and_parent(obj,node,pedge)








            ParentB=pedge.source;
            PS=obj.get_start_node(ParentB);
            PE=obj.get_end_node(ParentB);
            BS=obj.get_start_node(node);
            BE=obj.get_end_node(node);

            preds=block_in_parent(obj,node,pedge);





            clause=obj.empty_clause();
            clause(PE)=1;
            clause(BE)=-1;
            clause(BS)=1;
            preds=[preds;clause];

            clause=obj.empty_clause();
            clause(PS)=-1;
            clause(BE)=-1;
            clause(BS)=1;
            preds=[preds;clause];

        end





        function preds=block_in_parent(obj,node,pedge)











            ParentB=pedge.source;

            PS=obj.get_start_node(ParentB);
            PE=obj.get_end_node(ParentB);
            BS=obj.get_start_node(node);
            BE=obj.get_end_node(node);


            clause=obj.empty_clause();
            clause(BS)=-1;
            clause(PS)=1;
            preds=clause;



            clause=obj.empty_clause();
            clause(BE)=1;
            clause(PE)=-1;
            preds=[preds;clause];

        end





        function preds=mutex_action(obj,act)
            preds=[];
            Act=obj.get_edge_activation(act);
            for ActIdx=1:length(Act)









                for ActIdx2=ActIdx+1:length(Act)
                    if ActIdx2==ActIdx
                        continue;
                    elseif obj.equal_signal(act(ActIdx2),...
                        act(ActIdx))

                        continue;
                    end
                    clause=obj.empty_clause();
                    clause(Act(ActIdx))=-1;
                    clause(Act(ActIdx2))=-1;
                    preds=[preds;clause];
                end
            end


            clause=obj.empty_clause();
            for ActIdx=1:length(Act)
                clause(Act(ActIdx))=1;
            end
            preds=[preds;clause];

        end







        function preds=block_and_output(obj,node,out)










            preds=[];

            if isempty(out)
                return;
            end

            Out=obj.get_edge_ready(out);
            BE=obj.get_end_node(node);
            OutList=reshape(Out,1,numel(Out));

            for OutEl=OutList

                clause=obj.empty_clause();
                clause(BE)=-1;
                clause(OutEl)=1;
                preds=[preds;clause];
            end






            for OutEl=OutList

                clause=obj.empty_clause();
                clause(BE)=1;
                clause(OutEl)=-1;
                preds=[preds;clause];
            end
        end






        function preds=block_and_action(obj,node,act)



            preds=[];
            BS=obj.get_start_node(node);
            Act=obj.get_edge_ready(act);

            for ActEl=Act

                clause=obj.empty_clause();
                clause(ActEl)=-1;
                clause(BS)=1;
                preds=[preds;clause];
            end
        end





        function preds=input_and_block(obj,node,in)
            preds=[];







            BS=obj.get_start_node(node);
            if isempty(in)
                return;
            end
            Input=obj.get_edge_ready(in);
            for InEl=Input
                clause=obj.empty_clause();
                clause(BS)=-1;clause(InEl)=1;
                preds=[preds;clause];
            end
        end



        function preds=equivalence(obj,idx1,idx2)



            clause=obj.empty_clause();
            clause(obj.get_edge_ready(idx1))=-1;
            clause(obj.get_edge_ready(idx2))=1;
            preds=clause;

            clause=obj.empty_clause();
            clause(obj.get_edge_ready(idx1))=1;
            clause(obj.get_edge_ready(idx2))=-1;
            preds=[preds;clause];


            clause=obj.empty_clause();
            clause(obj.get_edge_activation(idx1))=-1;
            clause(obj.get_edge_activation(idx2))=1;
            preds=[preds;clause];

            clause=obj.empty_clause();
            clause(obj.get_edge_activation(idx1))=1;
            clause(obj.get_edge_activation(idx2))=-1;
            preds=[preds;clause];

        end

    end

    methods(Access=private)








        function preds=enabled_and_triggered(obj,nodeIdx)















            inedge=nodeIdx.in;

            enedge=find_enabled_edge(inedge,nodeIdx.combine.enabled_port);
            tredge=find_triggered_edge(inedge,nodeIdx.combine.triggered_port);
            pedge=find_parent_edge(inedge);
            preds=[];

            Enab=obj.get_edge_activation(enedge);
            Trig=obj.get_edge_activation(tredge);

            BS=obj.get_start_node(nodeIdx);
            BE=obj.get_end_node(nodeIdx);

            ParentB=pedge.source;
            PE=obj.get_end_node(ParentB);
            PS=obj.get_start_node(ParentB);















            clause=obj.empty_clause();
            clause(BS)=-1;
            for EnabEl=Enab
                clause(EnabEl)=1;
            end
            preds=[preds;clause];




            clause=obj.empty_clause();
            clause(BS)=-1;
            for TrigEl=Trig
                clause(TrigEl)=1;
            end
            preds=[preds;clause];





            for EnabEl=Enab
                for TrigEl=Trig
                    clause=obj.empty_clause();
                    clause(BS)=1;
                    clause(EnabEl)=-1;
                    clause(TrigEl)=-1;
                    clause(PE)=-1;
                    clause(PS)=-1;
                    preds=[preds;clause];
                end
            end









            for EnabEl=Enab
                for TrigEl=Trig
                    clause=obj.empty_clause();
                    clause(BS)=1;
                    clause(BE)=-1;
                    clause(EnabEl)=-1;
                    clause(TrigEl)=-1;
                    clause(PS)=-1;
                    preds=[preds;clause];
                end
            end



            for EnabEl=Enab
                for TrigEl=Trig
                    clause=obj.empty_clause();
                    clause(BS)=1;
                    clause(BE)=-1;
                    clause(EnabEl)=-1;
                    clause(TrigEl)=-1;
                    clause(PE)=1;
                    preds=[preds;clause];
                end
            end

            preds=[preds;obj.block_in_parent(nodeIdx,pedge)];

            depedges=find_dependent_edge(inedge);
            if~isempty(depedges)
                preds=[preds;obj.input_and_block(nodeIdx,depedges)];
            end

            outedge=nodeIdx.out;

            outdep=find_dependent_edge(outedge);
            if~isempty(outdep)
                preds=[preds;obj.block_and_output(nodeIdx,outdep)];
            end

            outedge=nodeIdx.out;
            outact=find_action_edge(outedge);

            assert(isempty(outact));

            childEdges=find_child_edge(outedge);
            preds=[preds;obj.one_active_child(childEdges)];
        end




        function preds=cec_si(obj,nodeIdx)

























            inedge=nodeIdx.in;



            fedge=find_action_edge(inedge);
            pedge=find_parent_edge(inedge);
            preds=[];
            if~isempty(fedge)

                Fire=obj.get_edge_activation(fedge);
                BS=obj.get_start_node(nodeIdx);
                BE=obj.get_end_node(nodeIdx);
                ParentB=pedge.source;
                PE=obj.get_end_node(ParentB);
                PS=obj.get_start_node(ParentB);






                clause=obj.empty_clause();
                clause(BS)=-1;
                for FireEl=Fire
                    clause(FireEl)=1;
                end
                preds=[preds;clause];
                if~isempty(nodeIdx.combine)&&...
                    isfield(nodeIdx.combine,'type')
                    if strcmp(nodeIdx.combine.type,...
                        'action')||...
                        strcmp(nodeIdx.combine.type,...
                        'fcn_call')








                        for FireEl=Fire
                            clause=obj.empty_clause();
                            clause(BS)=1;
                            clause(FireEl)=-1;
                            preds=[preds;clause];
                        end
                    else





                        for FireEl=Fire
                            clause=obj.empty_clause();
                            clause(BS)=1;
                            clause(FireEl)=-1;
                            clause(PE)=-1;
                            clause(PS)=-1;
                            preds=[preds;clause];
                        end

                    end
                end









                for FireEl=Fire
                    clause=obj.empty_clause();
                    clause(BS)=1;
                    clause(BE)=-1;
                    clause(FireEl)=-1;
                    clause(PS)=-1;
                    preds=[preds;clause];
                end



                for FireEl=Fire
                    clause=obj.empty_clause();
                    clause(BS)=1;
                    clause(BE)=-1;
                    clause(FireEl)=-1;
                    clause(PE)=1;
                    preds=[preds;clause];
                end


                preds=[preds;obj.block_in_parent(nodeIdx,pedge)];

                depedges=find_dependent_edge(inedge);
                if~isempty(depedges)
                    preds=[preds;obj.input_and_block(nodeIdx,depedges)];
                end

                outedge=nodeIdx.out;

                outdep=find_dependent_edge(outedge);
                if~isempty(outdep)
                    preds=[preds;obj.block_and_output(nodeIdx,outdep)];
                end

            elseif~isempty(pedge)

                preds=[preds;obj.regular_block(nodeIdx)];
            else

                preds=[preds;obj.starts(nodeIdx)];
            end

            outedge=nodeIdx.out;
            outact=find_action_edge(outedge);

            assert(isempty(outact));

            childEdges=find_child_edge(outedge);
            preds=[preds;obj.one_active_child(childEdges)];
        end




        function preds=regular_block(obj,nodeIdx)

            inedge=nodeIdx.in;
            pedge=find_parent_edge(inedge);
            preds=obj.block_and_parent(nodeIdx,pedge);

            inedge=nodeIdx.in;
            depedges=find_dependent_edge(inedge);
            preds=[preds;obj.input_and_block(nodeIdx,depedges)];

            outedge=nodeIdx.out;
            outdep=find_dependent_edge(outedge);
            preds=[preds;obj.block_and_output(nodeIdx,outdep)];

        end





        function preds=if_switchcase(obj,nodeIdx)


            inedge=nodeIdx.in;

            pedge=find_parent_edge(inedge);
            depedges=find_dependent_edge(inedge);
            if numel(pedge)~=1
                error('SATP:MoreThanOneParent',...
                'More than one parent edge found.');
            end

            outedge=nodeIdx.out;
            act=find_action_edge(outedge);

            preds=obj.input_and_block(nodeIdx,depedges);
            preds=[preds;obj.block_and_parent(nodeIdx,pedge)];
            preds=[preds;obj.mutex_action(act)];
            preds=[preds;obj.block_and_action(nodeIdx,act)];
        end
    end

    methods(Access=public)





        function satp=encode_model(obj)
            satp=[];
            for nodeIdx=1:obj.nNodes
                node=obj.graph.nodes(nodeIdx);
                switch node.node_type
                case 'context'
                    if~isempty(node.combine)&&...
                        isfield(node.combine,'type')&&...
                        strcmp(node.combine.type,...
                        'enabled_and_triggered')
                        satp=[satp;obj.enabled_and_triggered(node)];
                    else
                        satp=[satp;obj.cec_si(node)];
                    end
                case 'regular'
                    switch get_param(node.handle,'BlockType')
                    case 'If'
                        satp=[satp;obj.if_switchcase(node)];
                    case 'SwitchCase'
                        satp=[satp;obj.if_switchcase(node)];
                    otherwise
                        satp=[satp;obj.regular_block(node)];
                    end
                case 'leaf'
                    satp=[satp;obj.regular_block(node)];
                otherwise

                end
            end


            for i=1:length(obj.graph.edges)
                if strcmpi(obj.graph.edges(i).edge_type,'control')
                    for j=i+1:length(obj.graph.edges)

                        if obj.equal_signal(obj.graph.edges(i),...
                            obj.graph.edges(j))
                            satp=[satp;obj.equivalence(obj.graph.edges(i),...
                            obj.graph.edges(i))];
                        end
                    end
                end
            end


            idx=find_action_edge(obj.graph.edges);
            for i=1:length(idx)
                clause=obj.empty_clause();
                clause(obj.get_edge_activation(obj.graph.edges(i)))=-1;
                clause(obj.get_edge_ready(obj.graph.edges(i)))=1;
                satp=[satp;clause];
            end
        end
    end


    methods(Access=public)










        function preds=runs(obj,indices)

            preds=[];
            indlist=reshape(indices,1,numel(indices));
            for idx=indlist
                clause=obj.empty_clause();
                clause(obj.get_end_node(idx))=1;
                preds=[preds;clause];
                clause=obj.empty_clause();
                clause(obj.get_start_node(idx))=1;
                preds=[preds;clause];
            end

        end


        function preds=starts(obj,indices)

            preds=[];
            indlist=reshape(indices,1,numel(indices));
            for idx=indlist
                clause=obj.empty_clause();
                clause(obj.get_start_node(idx))=1;
                preds=[preds;clause];
                clause=obj.empty_clause();
                clause(obj.get_end_node(idx))=-1;
                preds=[preds;clause];
            end
        end


        function preds=not_runs(obj,indices)

            preds=[];
            ind=reshape(indices,1,numel(indices));
            for idx=ind
                clause=obj.empty_clause();
                clause(obj.get_start_node(idx))=-1;
                preds=[preds;clause];
            end

        end


        function preds=one_runs(obj,idx1,idx2)



            clause=obj.empty_clause();
            clause(obj.get_end_node(idx1))=-1;
            preds=clause;
            clause=obj.empty_clause();
            clause(obj.get_start_node(idx1))=1;
            preds=[preds;clause];

            clause=obj.empty_clause();
            clause(obj.get_start_node(idx2))=-1;
            preds=[preds;clause];
        end



    end
end

function child_edges=find_child_edge(edges)
    idx=[];
    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if edge.handle==-1
            idx=[idx,edgeIdx];
        end
    end
    child_edges=edges(idx);
end

function dep_edges=find_dependent_edge(edges)
    idx=[];
    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if numel(edge.handle)==1&&...
            edge.handle==-2
            idx=[idx,edgeIdx];
        end
    end
    dep_edges=edges(idx);
end

function edge=find_parent_edge(edges)

    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if edge.handle==-1
            return;
        end
    end
    edge=edges(1:-1);
end

function action_edges=find_action_edge(edges)

    action_edges=edges(1:-1);
    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if edge.handle(1)>0
            action_edges=[action_edges,edge];
        end
    end
end

function enabled_edges=find_enabled_edge(edges,enport)

    enabled_edges=edges(1:-1);
    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if edge.handle(1)>0&&edge.handle(1)==enport(1)
            enabled_edges=[enabled_edges,edge];
        end
    end
end

function triggered_edges=find_triggered_edge(edges,trigport)

    triggered_edges=edges(1:-1);
    for edgeIdx=1:length(edges)
        edge=edges(edgeIdx);
        if edge.handle(1)>0&&edge.handle(1)==trigport(1)
            triggered_edges=[triggered_edges,edge];
        end
    end
end
