function plist=getClientProperties(this,onlyVisible)







    plist=getClientPropertyList;

    if onlyVisible
        plist=plist([plist.Visible]);
    end

