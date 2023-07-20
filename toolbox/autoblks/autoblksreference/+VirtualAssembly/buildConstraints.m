


function Output=buildConstraints(ModelFile,ProductCatalogFile,ProductCatalogData,PlantModelType)


    if~isempty(ProductCatalogFile)
        if strcmp(PlantModelType,'Simulink')
            Components=readmatrix(ProductCatalogFile,'FileType','spreadsheet',...
            'Sheet','SimulinkComponents','OutputType','char','NumHeaderLines',1);
            Constraints=readmatrix(ProductCatalogFile,'FileType','spreadsheet',...
            'Sheet','SimulinkConstraints','OutputType','char','NumHeaderLines',1);
        else
            Components=readmatrix(ProductCatalogFile,'FileType','spreadsheet',...
            'Sheet','SimscapeComponents','OutputType','char','NumHeaderLines',1);
            Constraints=readmatrix(ProductCatalogFile,'FileType','spreadsheet',...
            'Sheet','SimscapeConstraints','OutputType','char','NumHeaderLines',1);
        end
    end


    num_all_components=size(Components,1);
    delete_component_index=[];
    for i=1:num_all_components
        if strcmp(Components{i,2},'inactive')
            delete_component_index=[delete_component_index,i];
        end
    end
    Components(delete_component_index,:)=[];


    n_components=size(Components,1);
    for i=1:n_components
        ComponentName=Components{i,1};
        ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
        ComponentPath=[];
        if~strcmp(Components{i,3},'none')&&~strcmp(Components{i,3},'dataset')
            for j=8:size(Components,2)
                if~strcmp(Components{i,j},'none')
                    ComponentPath=[ComponentPath,convertCharsToStrings(Components{i,j})];
                end
            end
        end
        eval([ComponentNameNoSpace,'= VirtualAssembly.VirtualAssemblyComponents(ModelFile,ComponentName,ComponentPath,Components{i,3},Components{i,5},ProductCatalogData);']);
    end


    G1=digraph;
    G2=digraph;

    for i=1:n_components
        G1=addnode(G1,Components{i,1});
        G2=addnode(G2,Components{i,1});
    end

    for i=1:n_components
        nodes=strsplit(Components{i,7},', ');
        if~strcmp(nodes{1,1},'none')
            NumOfNodes=size(nodes,2);
            for j=1:NumOfNodes
                if findnode(G1,nodes{j})~=0
                    G1=addedge(G1,Components{i,1},nodes{j});
                end
            end
        end
    end

    for i=1:n_components
        nodes=strsplit(Components{i,6},', ');
        if~strcmp(nodes{1,1},'none')
            NumOfNodes=size(nodes,2);
            for j=1:NumOfNodes
                if findnode(G2,nodes{j})~=0
                    G2=addedge(G2,Components{i,1},nodes{j});
                end
            end
        end
    end


    n_constraints=size(Constraints,1);
    for i=1:n_constraints
        MasterComponent=Constraints{i,1};
        MasterOption=Constraints{i,2};
        Condition=Constraints{i,3};
        RequestedComponent=Constraints{i,4};
        RequiredOption=Constraints{i,5};
        eval([MasterComponent,'.addConstraints(MasterOption,','Condition,',RequestedComponent,',RequiredOption);']);
    end


    for i=1:n_components
        ComponentName=Components{i,1};
        ComponentNameNoSpace=VirtualAssembly.NameFilter(ComponentName);
        Output.(ComponentNameNoSpace)=eval(ComponentNameNoSpace);
    end
    Output.ComponentAdjacency=G1;
    Output.ConstraintAdjacency=G2;



