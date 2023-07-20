function assignConfigSetUniqueName(this,configSet,blockDiagram,newNameRoot)





    ;


    newName=newNameRoot;
    count=0;

    if~isempty(blockDiagram)

        configSetNames=blockDiagram.getConfigSets;

        while any(strcmp(newName,configSetNames))

            newName=[newNameRoot,' ',num2str(count)];
            count=count+1;

        end

    end

    configSet.Name=newName;




