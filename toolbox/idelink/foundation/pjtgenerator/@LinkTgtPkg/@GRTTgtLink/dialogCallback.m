function dialogCallback(hObj,hDlg,tag,action)





    ObjProp=tag(length('Tag_ConfigSet_Target_')+1:end);


    feval([ObjProp,'_callback'],hObj,hDlg,tag,action);
    EnableApplyButton(hDlg);


    function CodeReplacementLibrary_callback(hObj,hDlg,tag,action)

        idx=getWidgetValue(hDlg,tag);
        try
            tr=RTW.TargetRegistry.get;
            NameList=tr.getTflNameList('nonSim',hObj);
            set(hObj,'CodeReplacementLibrary',NameList{idx+1});
        catch
            setEnabled(hDlg,tag,true);
            hParentController.ErrorDialog=errordlg(['Unknown Target Function Library selected.',...
            ' It is either unregistered or is not compatible with your current settings.',...
            ' Please choose another TFL from the list.']);
        end


        function DataExchangeInterface_callback(hObj,hDlg,tag,action)
            val=getWidgetValue(hDlg,tag);
            set(hObj,'RTWCAPIParams','off');
            set(hObj,'RTWCAPISignals','off');
            set(hObj,'GenerateASAP2','off');
            set(hObj,'ExtMode','off');
            switch val
            case 1
                set(hObj,'RTWCAPIParams','on');
                set(hObj,'RTWCAPISignals','on');
                setWidgetValue(hDlg,'Tag_ConfigSet_RTW_GRT_RTWCAPIParams',true);
                setWidgetValue(hDlg,'Tag_ConfigSet_RTW_GRT_RTWCAPISignals',true);
            case 2
                set(hObj,'ExtMode','on');
            case 3
                set(hObj,'GenerateASAP2','on');
            end


            function RTWCAPIParams_callback(hObj,hDlg,tag,action)
                val=getWidgetValue(hDlg,tag);
                set(hObj,'RTWCAPIParams',val);
                val2=strcmp(get(hObj,'RTWCAPISignals'),'on');
                if~val&&~val2
                    disp(['Warning: C-API will not be generated.  To generate C-API, either'...
                    ,' Signals or Parameters or both should be checked.']);
                    setWidgetValue(hDlg,'Tag_ConfigSet_RTW_GRT_DataExchangeInterface',0);
                end


                function RTWCAPISignals_callback(hObj,hDlg,tag,action)
                    val2=strcmp(get(hObj,'RTWCAPIParams'),'on');
                    val=getWidgetValue(hDlg,tag);
                    set(hObj,'RTWCAPISignals',val);
                    if~val&&~val2
                        disp(['Warning: C-API will not be generated.  To generate C-API, either'...
                        ,' Signals or Parameters or both should be checked.']);
                        setWidgetValue(hDlg,'Tag_ConfigSet_RTW_GRT_DataExchangeInterface',0);
                    end









                    function strout=OnOff(bool)
                        if(bool)
                            strout='on';
                        else
                            strout='off';
                        end


                        function strout=addsubtag(propstr)
                            subtag='Tag_ConfigSet_Target_';
                            strout=[subtag,propstr];


                            function EnableApplyButton(hDlg)

                                if~isempty(hDlg)&&isa(hDlg,'DAStudio.Dialog')
                                    hDlg.enableApplyButton(true);
                                end
