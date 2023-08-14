



function nonUniqueIds=checkUniqueCustomIds(this,dataReqSet)

    nonUniqueIds={};

    mfReqSet=dataReqSet.getModelObj();
    groups=mfReqSet.groups;
    for i=1:length(groups)
        group=groups(i);


        allKeys=group.externalReqs.keys();

        for j=1:length(allKeys)
            key=allKeys{j};

            values=group.externalReqs{key};
            if length(values)>1
                nonUniqueIds{end+1}=key;%#ok<AGROW>
            end
        end
    end

end
