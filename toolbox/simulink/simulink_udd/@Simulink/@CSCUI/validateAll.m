function validateAll(hUI)



    msg=DAStudio.message('Simulink:dialog:CSCUIValidateAllDefnsWait');


    slprivate('checkCSCDefnsForViolation',hUI,...
    hUI.AllDefns{1},hUI.AllDefns{2},msg);

