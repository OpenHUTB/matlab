function newDefn(hUI,buttonTag)




    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);


    switch whichDefns
    case 1
        if strcmp(buttonTag,'tcscNewButton')
            newDefn=Simulink.CSCDefn;
        end
        if strcmp(buttonTag,'tcscNewButtonRef')
            newDefn=Simulink.CSCRefDefn;
        end

        newType='CSC';

    case 2
        if strcmp(buttonTag,'tmsNewButton')
            newDefn=Simulink.MemorySectionDefn;
        end
        if strcmp(buttonTag,'tmsNewButtonRef')
            newDefn=Simulink.MemorySectionRefDefn;
        end
        newType='MemorySection';
    end

    newDefn.Name=LocalGetNewName(hUI,whichDefns,buttonTag);
    newDefn.OwnerPackage=hUI.CurrPackage;





    tmpDefns=[];
    for i=1:length(hUI.AllDefns{whichDefns})
        if i==currIndex+1
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i);newDefn];
        else
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i)];
        end
    end

    if isempty(tmpDefns)
        tmpDefns=[newDefn];
    else
        currIndex=currIndex+1;
    end

    hUI.AllDefns{whichDefns}=tmpDefns;
    hUI.Index(whichDefns)=currIndex;


    hUI.IsDirty=true;





    function newName=LocalGetNewName(hUI,whichDefns,buttonTag)

        existingDefns=hUI.AllDefns{whichDefns};

        switch whichDefns
        case 1
            if strcmp(buttonTag,'tcscNewButton')
                tmpstub='NewCSC';
            end
            if strcmp(buttonTag,'tcscNewButtonRef')
                tmpstub='NewCSCRef';
            end

        case 2
            if strcmp(buttonTag,'tmsNewButton')
                tmpstub='NewMS';
            end
            if strcmp(buttonTag,'tmsNewButtonRef')
                tmpstub='NewMSRef';
            end
        end

        countTry=1;
        while true
            newName=sprintf('%s_%d',tmpstub,countTry);
            countTry=countTry+1;
            if isempty(find(existingDefns,'Name',newName))
                break;
            end
        end





