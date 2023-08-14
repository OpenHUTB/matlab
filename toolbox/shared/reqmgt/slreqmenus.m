function schema=slreqmenus(fncname,cbinfo)


    fnc=str2func(fncname);
    schema=fnc(cbinfo);
end

function schema=SlreqEditor(~)%#ok<DEFNU>
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:SlReqEditor';
    schema.label=getString(message('Slvnv:slreq:RequirementsEditorALTQ'));



    schema.callback=@OpenStandaloneEditor_callback;
    schema.autoDisableWhen='Busy';
end

function OpenStandaloneEditor_callback(~)
    slreq.app.MainManager.getInstance.openRequirementsEditor();
end






function schema=SlreqSpreadsheet(cbInfo)%#ok<DEFNU>
    schema=DAStudio.ToggleSchema;
    schema.tag='Simulink:SlReqSpreadsheetToggle';
    schema.label=getString(message('Slvnv:slreq:RequirementsPerspectiveSpreadsheetALTQ'));
    if~slreq.utils.isInPerspective(cbInfo.model.Handle,false)

        schema.state='Hidden';
    else
        if loc_isSpreadsheetShown(cbInfo)
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end
        schema.callback=@TogleReqSpreadsheet_callback;
    end
    schema.autoDisableWhen='Busy';
end

function tf=loc_isSpreadsheetShown(cbInfo)
    tf=false;
    if slreq.app.MainManager.exists()
        mMgr=slreq.app.MainManager.getInstance;
        if~isempty(mMgr.perspectiveManager)


            modelH=cbInfo.model.Handle;
            spObj=mMgr.getSpreadSheetObject(modelH);
            tf=~isempty(spObj)&&spObj.isComponentVisible;
        end
    end
end

function TogleReqSpreadsheet_callback(cbInfo)
    mMgr=slreq.app.MainManager.getInstance;
    modelH=cbInfo.model.Handle;
    spObj=mMgr.getSpreadSheetObject(modelH);
    if spObj.isComponentVisible()
        spObj.hide();
    else


        spObj.show(cbinfo.studio,true);
    end
end

