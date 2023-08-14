function hdltoolstrip(modelname)




    if nargin<1
        modelname=bdroot;
    end

    modelname=convertStringsToChars(modelname);

    if~ischar(modelname)
        warning(message('hdlcommon:hdlcommon:hdlsetup'));
        return
    end

    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    editors=GLUE2.Util.findAllEditors(modelname);

    idx=arrayfun(@(x)any(editors==x.App.getActiveEditor),studios);

    ts=studios(idx(1)).getToolStrip;

    ts.getActionService().executeActionSync('hdlCoderAppAction',true)

end
