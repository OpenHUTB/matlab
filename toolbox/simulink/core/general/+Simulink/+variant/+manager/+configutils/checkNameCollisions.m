function[hasCollision,collidingVars]=checkNameCollisions(controlVariables)






    hasCollision=false;
    collidingVars={};

    if isempty(controlVariables)
        return;
    end




    if isfield(controlVariables,'Source')

        fieldNames=fieldnames(controlVariables);
        controlVarCell=struct2cell(controlVariables);
        sz=size(controlVarCell);
        controlVarCell=reshape(controlVarCell,sz(1),[]);


        controlVarCell=controlVarCell';



        controlVarCell=cellfun(@(x)convertStringsToChars(x),controlVarCell,'UniformOutput',false);


        controlVarCell=sortrows(controlVarCell,3);
        controlVarCell=reshape(controlVarCell',sz);


        controlVarSorted=cell2struct(controlVarCell,fieldNames,1);


        varNamesAsPerSources.Vars={};
        varNamesAsPerSources.Source=controlVarSorted(1).Source;
        indexForVars=1;
        for index=1:size(controlVarSorted,2)
            if strcmp(varNamesAsPerSources(indexForVars).Source,controlVarSorted(index).Source)
                varNamesAsPerSources(indexForVars).Vars{end+1}=controlVarSorted(index).Name;%#ok<AGROW>
            else
                indexForVars=indexForVars+1;
                varNamesAsPerSources(indexForVars).Vars={};%#ok<AGROW>
                varNamesAsPerSources(indexForVars).Vars{end+1}=controlVarSorted(index).Name;%#ok<AGROW>
                varNamesAsPerSources(indexForVars).Source=controlVarSorted(index).Source;%#ok<AGROW>
            end

        end
    else
        varNamesAsPerSources.Vars={};
        for index=1:size(controlVariables,2)
            varNamesAsPerSources.Vars{end+1}=controlVariables(index).Name;
        end
    end




    for index=1:size(varNamesAsPerSources,2)
        varNames=varNamesAsPerSources(index).Vars;

        processedVarNames=checkForNameCollisions(varNames);

        if size(processedVarNames,2)~=size(varNames,2)


            for ind=1:size(varNames,2)
                if isempty(find(contains(processedVarNames,varNames{ind}),1))
                    collidingVars{end+1}=varNames{ind};%#ok<AGROW>
                end
            end
            hasCollision=true;
            break;
        end
    end
end













function vars=checkForNameCollisions(varNames)


    topLevelVar={};
    for index=1:length(varNames)
        varSplit=strsplit(varNames{index},{'.','{','}','(',')'});
        topLevelVar{end+1}=varSplit{1};%#ok<AGROW>
    end

    index=1;
    varNamesDup=varNames;
    vars={};
    while~isempty(topLevelVar)
        dupIds=ismember(topLevelVar,topLevelVar{index});

        vars=[vars,checkForValidEntries(varNamesDup(dupIds))];%#ok<AGROW>


        topLevelVar(dupIds)=[];%#ok<AGROW>
        varNamesDup(dupIds)=[];

    end
end



function val=hasMultipleDots(data)
    val=false;
    for index=1:length(data)
        splitElement=strsplit(data{index},'.');
        if numel(splitElement)>2
            val=true;
        end
    end
end










function validEntries=checkForValidEntries(completeEntries)

    indexOfFieldsWithDot=contains(completeEntries,'.');
    if sum(indexOfFieldsWithDot)==numel(completeEntries)

        if hasMultipleDots(completeEntries)
            modEntries=completeEntries;
            for index=1:length(completeEntries)
                indexOfDots=regexp(completeEntries{index},'\.');
                temp=modEntries{index};
                modEntries{index}=temp(indexOfDots+1:end);
            end

            validModEntries=checkForValidEntries(modEntries);




            if numel(validModEntries)>1
                validEntries=completeEntries;
                return;
            end



            for index=1:length(modEntries)
                if strcmp(modEntries{index},validModEntries)
                    validEntries=completeEntries{index};
                    return;
                end
            end

            return;
        end

        validEntries=completeEntries;
        return;
    end




    indexForNormVariable=cellfun(@isvarname,completeEntries);
    if~isempty(find(indexForNormVariable,1))
        validEntries=completeEntries(find(indexForNormVariable,1));
        return;
    end


    indexForArray=find(contains(completeEntries,'('),1);
    if~isempty(indexForArray)
        validEntries=completeEntries(indexForArray);
        return;
    end


    indexForCellArray=find(contains(completeEntries,'{'),1);
    if~isempty(indexForCellArray)
        validEntries=completeEntries(indexForArray);
        return;
    end
end
