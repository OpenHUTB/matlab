function[harnessName,harnessToDelete]=getSLDVHarnessName(model,owner,opts)
    hList=Simulink.harness.internal.getHarnessList(model,'all');
    n=length(hList);
    existingHarnessNames=cell(1,n);
    for i=1:n
        hList(i).inMem=Simulink.harness.internal.isInMemory(get_param(hList(i).model,'Handle'),...
        hList(i).name,hList(i).ownerHandle);
        existingHarnessNames{i}=hList(i).name;
    end

    activeHarnes=Simulink.harness.find(model,'OpenOnly','on');
    tmpName=opts.SlTestHarnessName;
    tmpName=strrep(tmpName,'$ModelName$',model);
    candName=tmpName;
    uniqueFlag=strcmp(opts.MakeOutputFilesUnique,'on');
    id=1;
    inMemoryModels=lower(find_system('type','block_diagram'));
    harnessToDelete=[];
    while true
        [~,ind]=ismember(candName,existingHarnessNames);
        if ind==0
            harnessName=candName;


            [~,ind1]=ismember(lower(candName),inMemoryModels);
            nameConflictsWithInMemoryModels=(ind1~=0);


            nameIsShadowing=~isempty(which(candName));

            if~nameConflictsWithInMemoryModels&&~nameIsShadowing
                return;
            end
        else
            if(uniqueFlag==false&&...
                hList(ind).inMem==0&&...
                strcmp(hList(ind).ownerFullPath,owner)&&...
                isempty(activeHarnes))

                harnessToDelete=hList(ind);
                harnessName=candName;
                return;
            end
        end
        candName=[tmpName,num2str(id)];
        id=id+1;
    end
end
