function popup_menu=getContextMenu(this,~)




    popup_menu=[];

    me=this.coreObj.HierAnalyzer.getAdvisorUI;
    advisor=this.coreObj.HierAnalyzer;

    if isempty(me)
        return;
    end
    try
        am=DAStudio.ActionManager;
        popup_menu=am.createPopupMenu(me);

        block_sid=this.coreObj.Sid;
        model_sid=Simulink.ID.getSID(this.coreObj.HierAnalyzer.getModelHandle);

        check_component=am.createAction(me);
        check_component.text=getString(message('Sldv:ComponentAdvisor:CheckComponent_CM'));
        check_component.callback=['sldvprivate(','''component_advisor_cb'',''',model_sid,''',','''recheck_component'', ''',block_sid,''')'];



        enable_check=~advisor.isAnalysisRunning&&((this.coreObj.DerivedAnalysisState==Sldv.Advisor.MdlCompState.NotProcessedYet)||...
        (this.coreObj.DerivedAnalysisState==Sldv.Advisor.MdlCompState.NotAnalyzable));
        if enable_check
            check_component.enabled='on';
        else
            check_component.enabled='off';
        end
        popup_menu.addMenuItem(check_component);




        check_hierarchy=am.createAction(me);
        check_hierarchy.text=getString(message('Sldv:ComponentAdvisor:CheckComponentHier_CM'));
        check_hierarchy.callback=['sldvprivate(','''component_advisor_cb'',''',model_sid,''',','''recheck_hierarchy'', ''',block_sid,''')'];




        if~this.coreObj.isLeaf&&enable_check
            check_hierarchy.enabled='on';
        else
            check_hierarchy.enabled='off';
        end
        popup_menu.addMenuItem(check_hierarchy);

    catch Mex


        MSLDiagnostic(Mex).reportAsWarning;
    end

end

