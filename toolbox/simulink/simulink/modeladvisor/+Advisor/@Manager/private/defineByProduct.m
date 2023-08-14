function nodes=defineByProduct(groupedrecordTree,checkCellArray)


    nodes={};


    if~isempty(groupedrecordTree)
        groupedrecordTree.name=DAStudio.message('Simulink:tools:MAByProduct');
        nodes=loc_GetByProductTree(groupedrecordTree,checkCellArray,'_SYSTEM');
    end
    if length(nodes)>1
        nodes{1}.Published=true;
    end






    function nodes=loc_GetByProductTree(tree,checkCellArray,IDPrefix)
        nodes={};

        if strcmp(IDPrefix,'_SYSTEM')
            ID=[IDPrefix,'_','By Product'];
        else
            ID=[IDPrefix,'_',tree.name];
        end
        TAN=ModelAdvisor.Group(ID);
        TAN.DisplayName=tree.name;

        TAN=modeladvisorprivate('modeladvisorutil2','SetFolderCSH',TAN);
        TAN.ChildrenMACIndex=tree.Nodes;
        nodes{end+1}=TAN;


        for i=1:length(tree.Groups)
            subTree=loc_GetByProductTree(tree.Groups{i},checkCellArray,TAN.ID);
            nodes=[nodes,subTree];%#ok<AGROW>
            TAN.Children{end+1}=subTree{1}.ID;

        end


        for i=1:length(tree.Nodes)
            if checkCellArray{tree.Nodes{i}}.Published
                activeNode=modeladvisorprivate('modeladvisorutil2','createTANFromCheck',checkCellArray,tree.Nodes{i},[TAN.ID,'_']);
                nodes{end+1}=activeNode;%#ok<AGROW>
                TAN.Children{end+1}=activeNode.ID;
            end
        end
