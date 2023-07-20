function showCheckSelectorUI(this,callbackInfo)

    propValues=callbackInfo.UserData.prop;


    if strcmp(propValues.checkIDs,'.*')
        propValues.checkIDs=['All Checks'];
        this.addExclusion(propValues);
        this.bringToFront();
    elseif strcmp(propValues.checkIDs,DAStudio.message('slcheck:filtercatalog:CheckSelectorGUI'))

        this.closeChildWindows();


        CSW=Advisor.CheckSelector();


        CSW.setParent(this);

        CSW.setInitPropValues(propValues);


        this.childWindow=CSW;


        CSW.open();

    else
        this.addExclusion(propValues);
        this.bringToFront();
    end
end
