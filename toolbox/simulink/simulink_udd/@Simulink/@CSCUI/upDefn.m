function upDefn(hUI)




    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);

    if currIndex==0
        return;
    end

    tmpDefns=[];
    for i=1:length(hUI.AllDefns{whichDefns})
        if i==currIndex
            tmp=hUI.AllDefns{whichDefns}(i);
        elseif i==currIndex+1
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i);tmp];
        else
            tmpDefns=[tmpDefns;hUI.AllDefns{whichDefns}(i)];
        end
    end

    hUI.AllDefns{whichDefns}=tmpDefns;
    hUI.setIndex(currIndex-1);


    hUI.IsDirty=true;



