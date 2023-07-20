function[numcycles,cycles]=findCycles(adjList)

















    if~issparse(adjList)
        adjList=sparse(adjList);
    end

    n=size(adjList,1);

    Blist=cell(n,1);

    blocked=false(1,n);

    s=1;
    cycles={};
    stack=[];


    function f=circuit(v,s,C)
        f=false;

        stack(end+1)=v;
        blocked(v)=true;

        for w=find(C(v,:))
            if w==s
                cycles{end+1}=[stack,s];
                f=true;
            elseif~blocked(w)
                if circuit(w,s,C)
                    f=true;
                end
            end
        end

        if f

            blocked(v)=false;
            for w=Blist{v}
                if blocked(w)
                    blocked(w)=false;
                end
            end
            Blist{v}=[];
        else
            for w=find(C(v,:))
                if~ismember(v,Blist{w})
                    Bnode=Blist{w};
                    Blist{w}=[Bnode,v];
                end
            end
        end

        stack(end)=[];
    end


    while s<n


        F=adjList;
        F(1:s-1,:)=0;
        F(:,1:s-1)=0;

        [ci,sizec]=Advisor.Utils.Graph.getStronglyConnectedComponents(F);

        if any(sizec>=2)

            cycle_components=find(sizec>=2);
            least_node=find(ismember(ci,cycle_components),1);
            comp_nodes=find(ci==ci(least_node));

            Ak=sparse(n,n);
            Ak(comp_nodes,comp_nodes)=F(comp_nodes,comp_nodes);

            s=comp_nodes(1);
            blocked(comp_nodes)=false;
            Blist(comp_nodes)=cell(length(comp_nodes),1);
            circuit(s,s,Ak);
            s=s+1;

        else
            break;
        end
    end

    numcycles=length(cycles);

end