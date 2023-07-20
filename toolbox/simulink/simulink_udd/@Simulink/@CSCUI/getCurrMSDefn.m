function msDefn=getCurrMSDefn(hUI)



    msDefn=[];

    if hUI.Index(2)<length(hUI.AllDefns{2})
        msDefn=hUI.AllDefns{2}(hUI.Index(2)+1);
    end



