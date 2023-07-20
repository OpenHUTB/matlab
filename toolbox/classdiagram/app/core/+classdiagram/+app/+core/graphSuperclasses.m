function[G,Gdirect,Gindirect,Gnonexpandable]...
    =graphSuperclasses(keep,factory)


    target_nodes=keep;
    source_nodes=keep;
    visited_nodes=cell(0);

    testnames=unique(keep);

    while~isempty(testnames)
        new_children=cell(0);
        new_parents=cell(0);

        for ichild=1:numel(testnames)
            child=testnames(ichild);
            parents=getSuperclassNamesForClassName(child,factory);

            new_parents(end+1:end+numel(parents))=parents;
            new_children(end+1:end+numel(parents))=child;
        end

        visited_nodes(end+1:end+numel(testnames))=testnames;

        source_nodes(end+1:end+numel(new_parents))=new_parents;
        target_nodes(end+1:end+numel(new_children))=new_children;



        testnames=setdiff(new_parents,visited_nodes);
    end








    excludeMixins=false;
    [G,Gdirect,Gindirect]=buildGraph(source_nodes,target_nodes,keep,excludeMixins);


    excludeMixins=true;
    [~,~,GindirectExpandable]=buildGraph(source_nodes,target_nodes,keep,excludeMixins);



    ge=GindirectExpandable.Edges{:,1};
    expandableStartNodes=ge(:,1);
    expandableEndNodes=ge(:,2);

    Gnonexpandable=rmedge(Gindirect,expandableStartNodes,expandableEndNodes);
end



function[G,Gdirect,Gindirect]=buildGraph(source_nodes,target_nodes,keep,excludeMixins)

    function mixinsIdx=mixins(classNames)
        mixinsIdx=ismember(classNames,...
        ['handle',classdiagram.app.core.utils.Constants.Mixins]);
    end

    if excludeMixins




        keeperIdx=(ismember(source_nodes,keep)|~mixins(source_nodes))&...
        (ismember(target_nodes,keep)|~mixins(target_nodes));
        source_nodes=source_nodes(keeperIdx);
        target_nodes=target_nodes(keeperIdx);
    end







    edgetype=ismember(source_nodes,keep)+2*ismember(target_nodes,keep);
    G=digraph(source_nodes,target_nodes,'omitselfloops');
    KK=edgetype==3;
    OK=edgetype==2;
    KO=edgetype==1;
    OO=edgetype==0;

    Gdirect=digraph(source_nodes(KK),target_nodes(KK),'omitselfloops');







    G3=digraph([keep,source_nodes(KO|OO)],[keep,target_nodes(KO|OO)],'omitselfloops');

    G4=transclosure(G3);


    G5=addedge(G4,source_nodes(OK),target_nodes(OK));


    A=adjacency(G5);




    Gindirect=subgraph(digraph(A*A,G5.Nodes.Name),keep);




end

function names=getSuperclassNamesForClassName(name,factory)
    names={};
    cls=factory.getPackageElement(name{:});
    if~isempty(cls)
        supers=factory.getSuperclasses(cls);
        if~isempty(supers)
            names=cellstr(arrayfun(@(super)super.getName(),supers,'UniformOutput',false));
        end
    end
end
