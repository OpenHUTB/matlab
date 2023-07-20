function check_nodes(nl,filename)







    Erreur.message=['Invalid nodal matrix in ',filename];
    Erreur.identifier='SpecializedPowerSystems:PowerSysDomain:InvalidNodalMatrix';













    [n,m]=size(nl.portToNode);





    if(m~=length(nl.ports))
        psberror(Erreur);
    end




    if(isempty(nl.nodes))
        max_node=0;
    else
        max_node=max(nl.nodes(:));
    end

    if(max_node+1>n)
        psberror(Erreur);
    end