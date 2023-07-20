function fList=makeFunctionList(c,wList,vList)





    if isempty(wList)
        fList=cell(0,4);
        return
    end

    if nargin<2||isempty(vList)


        filterStrings={'on','off','auto','inf','held'};
    else

        filterStrings={'on','off','auto','inf','held',vList{:,1}};
    end

    [~,aIndex]=setxor(wList(:,1),filterStrings);

    fnIndex=[];

    for i=1:length(aIndex)
        symbolName=wList{aIndex(i),1};
        whichResult=which(symbolName);
        if strncmp(whichResult,'built-in',8)
            listInclude=true;
        elseif isempty(whichResult)||strcmp(whichResult,'variable')||...
            ~contains(whichResult,symbolName)
            listInclude=false;
        elseif strcmpi(whichResult(end-1:end),'.m')||...
            strcmpi(whichResult(end-1:end),'.p')
            listInclude=true;
        else
            listInclude=false;
        end


        if listInclude
            fnIndex=[fnIndex,aIndex(i)];%#ok<AGROW> 
        end
    end

    fList=wList(fnIndex,:);

