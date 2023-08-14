function nameDefn(hUI,val)




    whichDefns=hUI.mainActiveTab+1;
    currIndex=hUI.Index(whichDefns);
    currDefn=hUI.AllDefns{whichDefns}(currIndex+1);




    if isempty(val)
        msg=DAStudio.message('Simulink:dialog:CSCUINameDefnEmpty');
        errordlg(msg,...
        DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;
    end




    if strcmp(val,'Default')
        msg=DAStudio.message('Simulink:dialog:CSCUINameDefnDefaultReserve');
        errordlg(msg,...
        DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;

    elseif strcmp(val,'Instance specific')
        msg=DAStudio.message('Simulink:dialog:CSCUINameDefnInstantSpecific');
        errordlg(msg,...
        DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        return;
    end




    for i=1:length(hUI.AllDefns{whichDefns})
        if i==currIndex+1
            continue;
        end

        tmpName=hUI.AllDefns{whichDefns}(i).Name;

        if strcmp(val,tmpName)

            msg=DAStudio.message('Simulink:dialog:CSCUINameDefnUniqName');
            errordlg(msg,...
            DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
            return;
        end
    end


    currDefn.Name=val;


    hUI.IsDirty=true;



