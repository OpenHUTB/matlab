function matchList=TagSearch(hThis,tagStr,matchOpt,SearchOpt)

















    tmpObjList=[];
    continueSrch=true;
    [tmpObjList,continueSrch]=l_TagRecursSearch(hThis,tagStr,matchOpt,SearchOpt,tmpObjList,continueSrch);
    matchList=tmpObjList;
end

function[objList,keepSearching]=l_TagRecursSearch(hThis,tagStr,matchOpt,SearchOpt,objList,keepSearching)

    if(~keepSearching)
        objList=objList;
        return;
    end

    nItems=length(hThis.Items);
    for idx=1:nItems
        if(~keepSearching)
            objList=objList;
            return;
        end

        isMatch=CompareTagStrings(hThis.Items(idx).ObjId,tagStr,matchOpt);
        if(isMatch)
            if(isempty(objList))
                objList=hThis.Items(idx);
            else
                objList(end+1)=hThis.Items(idx);
            end

            if(strcmpi(SearchOpt,'First'))

                keepSearching=false;
                return;
            end
        end

        [objList,keepSearching]=l_TagRecursSearch(hThis.Items(idx),tagStr,...
        matchOpt,SearchOpt,objList,keepSearching);
    end
end

function isMatch=CompareTagStrings(searchStr,objTagStr,option)
    if(strcmpi(option,'Exact'))
        isMatch=strcmp(searchStr,objTagStr);
    else
        isMatch=~isempty(findstr(objTagStr,searchStr));
    end
end
