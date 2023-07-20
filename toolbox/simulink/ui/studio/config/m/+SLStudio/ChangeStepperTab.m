function ChangeStepperTab(dlg,~,idx)

    obj=dlg.getSource();
    obj.currentTabIndex=idx+1;
    dlg.refresh;
end
