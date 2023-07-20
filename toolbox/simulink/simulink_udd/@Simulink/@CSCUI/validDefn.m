function validDefn(hUI)




    currDefn=getCurrDefn(hUI);
    if isempty(currDefn)
        hUI.InvalidList={{},{}};
        return;
    end

    if isa(currDefn,'Simulink.CSCDefn')

        errs=evalc('currDefn.TLCFileName = currDefn.TLCFileName;');
        if~isempty(errs)
            warndlg(lastwarn,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        end
    end


    [tmpCSCDefn,tmpMSDefn]=getDefnsForValidation(currDefn,hUI);

    msg=DAStudio.message('Simulink:dialog:CSCUIValidateDefnWait');

    slprivate('checkCSCDefnsForViolation',hUI,...
    tmpCSCDefn,tmpMSDefn,msg);




