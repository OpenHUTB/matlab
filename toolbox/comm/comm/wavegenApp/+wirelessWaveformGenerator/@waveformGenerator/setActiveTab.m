function setActiveTab(obj,idx)




    if idx==1
        obj.pTabGroup.remove(obj.pRadioTab);
        obj.pTabGroup.add(obj.pWavegenTab);
    else
        obj.pTabGroup.remove(obj.pWavegenTab);
        obj.pTabGroup.add(obj.pRadioTab);
    end