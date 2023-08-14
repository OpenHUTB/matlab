function nl=joint_nodes(nl,MasterNode,NodeToKill)






    Noeuds=nl.nodes;
    for j=1:size(nl.nodes,1)
        indicesfound=find(Noeuds{j}==NodeToKill);
        if~isempty(indicesfound)
            Noeuds{j}(indicesfound)=MasterNode;
        end
    end
    nl.nodes=Noeuds;