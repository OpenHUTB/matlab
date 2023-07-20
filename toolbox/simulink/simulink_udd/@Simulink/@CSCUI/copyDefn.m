function copyDefn(hUI)




    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);
    currDefn=hUI.AllDefns{whichDefns}(currIndex+1);


    copyDefn=currDefn.deepCopy;
    copyDefn.Name=LocalGetCopyName(hUI,whichDefns,currDefn.Name);
    copyDefn.OwnerPackage=hUI.CurrPackage;





    tmpDefns=[];
    for i=1:length(hUI.AllDefns{whichDefns})
        if i==currIndex+1
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i);copyDefn];%#ok
        else
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i)];%#ok
        end
    end

    if isempty(tmpDefns)
        tmpDefns=copyDefn;
    else
        currIndex=currIndex+1;
    end

    hUI.AllDefns{whichDefns}=tmpDefns;
    hUI.Index(whichDefns)=currIndex;


    hUI.IsDirty=true;





    function copyName=LocalGetCopyName(hUI,whichDefns,origName)

        existingDefns=hUI.AllDefns{whichDefns};
        existingNames={};
        if~isempty(existingDefns)
            for i=1:length(existingDefns)
                existingNames{i}=existingDefns(i).Name;%#ok
            end
        end

        tmpstub=origName;

        countTry=1;
        while true
            copyName=sprintf('%s_%d',tmpstub,countTry);
            countTry=countTry+1;
            if~ismember(copyName,existingNames)
                break;
            end
        end





