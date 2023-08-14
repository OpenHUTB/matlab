function currDefn=getCurrDefn(hUI)




    currDefn=[];

    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);

    if currIndex<length(hUI.AllDefns{whichDefns})
        currDefn=hUI.AllDefns{whichDefns}(currIndex+1);
    end



