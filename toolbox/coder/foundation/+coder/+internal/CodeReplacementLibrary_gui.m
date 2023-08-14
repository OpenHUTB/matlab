function[lhsLibraries,rhsLibraries]=CodeReplacementLibrary_gui(lTargetRegistry,supportedLibraries,selectedLibraries)
    totalNum=length(supportedLibraries);
    lhsLibraries=[];
    lineBreaker='<br>';

    for i=1:totalNum
        thisCrl=supportedLibraries{i};


        if(strcmpi(thisCrl,'None'))
            continue;
        end

        current.Name=thisCrl;
        current.Id=i;
        current.Description=coder.internal.getTooltip(lTargetRegistry,thisCrl,lineBreaker);
        lhsLibraries=[lhsLibraries,current];%#ok<AGROW>
    end





    supportedLibraryMap=containers.Map({lhsLibraries.Name},{lhsLibraries.Id});
    rhsNum=length(selectedLibraries);
    rhsNameSet=[];
    rhsLibraries=[];
    for i=1:rhsNum
        thisCrl=selectedLibraries{i};
        if isKey(supportedLibraryMap,thisCrl)
            current.Name=thisCrl;
            current.Id=supportedLibraryMap(thisCrl);
            current.Description=coder.internal.getTooltip(lTargetRegistry,thisCrl,lineBreaker);
            rhsNameSet=[rhsNameSet,{current.Name}];%#ok<AGROW>
            rhsLibraries=[rhsLibraries,current];%#ok<AGROW>
        end
    end




    lhsLen=length(lhsLibraries);
    idxToRemove=[];
    for i=1:lhsLen

        if~isempty(rhsNameSet)&&any(strcmp(rhsNameSet,lhsLibraries(i).Name))
            idxToRemove=[idxToRemove,i];%#ok<AGROW>
        end
    end
    lhsLibraries(idxToRemove)=[];

    if isempty(lhsLibraries)
        lhsLibraries=struct('Name',{},'Id',{},'Description',{});
    end

    if isempty(rhsLibraries)
        rhsLibraries=struct('Name',{},'Id',{},'Description',{});
    end
end
