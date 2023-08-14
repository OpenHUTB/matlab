function isVarLocs=fastIsVariableLocation(locations)



    persistent varTypes;
    persistent knownSizes;
    persistent total;
    if isempty(varTypes)
        varTypes={'var','inputVar','outputVar','globalVar','persistentVar'};
        knownSizes=sort(cellfun(@numel,varTypes));
        total=numel(varTypes);
    end

    locCount=numel(locations);
    if locCount>0
        isVarLocs=false(locCount,1);
        typeNames={locations.NodeTypeName};
        for i=1:locCount
            isVarLocs(i)=doit(typeNames{i});
        end
    else
        isVarLocs=[];
    end

    function isVarLoc=doit(typeName)
        isVarLoc=false;
        nameLen=numel(typeName);
        compStart=0;

        low=1;
        high=total;
        while low<=high
            mid=floor((low+high)/2);
            val=knownSizes(mid);
            if nameLen==val
                compStart=mid;
                break;
            elseif nameLen<val
                high=mid-1;
            else
                low=mid+1;
            end
        end

        if compStart>0
            for j=compStart:total
                varType=varTypes{j};
                if(j==compStart||knownSizes(j)==nameLen)
                    if strcmp(typeName,varType)
                        isVarLoc=true;
                        break;
                    end
                else
                    break;
                end
            end
        end

    end
end

