function checkCSCDefnsForViolation(hUI,CSCDefns,MSDefns,msg)




    waitBarPlsWait=DAStudio.message('Simulink:dialog:CSCUIFindPkgsPlsWait');
    hw=waitbar(0,msg,'Name',waitBarPlsWait);

    invalidList=validatecsc(hUI.RegFileInfo{1},CSCDefns,MSDefns);
    hUI.InvalidList=invalidList;

    if ishghandle(hw);
        waitbar(1,hw);
        close(hw);
    end

    warnMsg='';


    for i=1:size(invalidList{2},2)
        invalidDefn=invalidList{2}(:,i);
        warnMsg=[warnMsg,DAStudio.message('Simulink:dialog:InvalidMSDefn',...
        invalidDefn{1},invalidDefn{2}),char(10),char(10)];%#ok
    end
    if~isempty(warnMsg)
        warndlg(warnMsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;
    end


    for i=1:size(invalidList{1},2)
        invalidDefn=invalidList{1}(:,i);
        warnMsg=[warnMsg,DAStudio.message('Simulink:dialog:InvalidCSCDefn',...
        invalidDefn{1},invalidDefn{2}),char(10),char(10)];%#ok               
    end
    if~isempty(warnMsg)
        warndlg(warnMsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
    end

