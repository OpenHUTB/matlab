function cscDefn=getCurrCSCDefn(hUI)



    cscDefn=[];

    if hUI.Index(1)<length(hUI.AllDefns{1})
        cscDefn=hUI.AllDefns{1}(hUI.Index(1)+1);
    end



