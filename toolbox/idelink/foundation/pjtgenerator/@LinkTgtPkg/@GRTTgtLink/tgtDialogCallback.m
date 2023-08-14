function tgtDialogCallback(hObj,hDlg,tag,action)














    ObjProp=tag(length('Tag_ConfigSet_Target_')+1:end);


    feval([ObjProp,'_callback'],hObj,hDlg,tag,action);
    EnableApplyButton(hDlg);


    function exportIDEObj_callback(hObj,hDlg,tag,action)
        val=hDlg.getWidgetValue(tag);
        setProp(hObj,'exportIDEObj',OnOff(val));



        function ideObjName_callback(hObj,hDlg,tag,action)
            hSrc=hObj.getSourceObject;
            hConfigSet=hSrc.getConfigSet;
            if~isempty(hConfigSet)
                hParentController=hConfigSet.getDialogController;
            else
                hParentController=hObj;
            end
            val=hDlg.getWidgetValue(tag);
            if~iscvar(val)
                hParentController.ErrorDialog=errordlg('IDE link handle name is not valid variable name.','Invalid Handle Name','modal');
                hObj.ideObjName=hObj.oldideObjName;
            else
                hObj.oldideObjName=hObj.ideObjName;
            end


            function ideObjTimeout_callback(hObj,hDlg,tag,action)
                setNumericWidgetValue(hObj,hDlg,tag,action,'ideObjTimeout','Time-out');


                function ideObjBuildTimeout_callback(hObj,hDlg,tag,action)
                    setNumericWidgetValue(hObj,hDlg,tag,action,'ideObjBuildTimeout','Build time-out');


                    function setNumericWidgetValue(hObj,hDlg,tag,action,widgetName,desc)
                        hSrc=hObj.getSourceObject;
                        hConfigSet=hSrc.getConfigSet;
                        if~isempty(hConfigSet)
                            hParentController=hConfigSet.getDialogController;
                        else
                            hParentController=hObj;
                        end
                        try
                            val=eval(hDlg.getWidgetValue(tag));
                            if~isnumeric(val)||numel(val)>1||val<=0
                                hParentController.ErrorDialog=...
                                errordlg([desc,' must be a numeric value greater than zero.'],'Invalid Time-out Value','modal');
                                hObj.(widgetName)=hObj.(['old',widgetName]);
                            else
                                hObj.(['old',widgetName])=hObj.(widgetName);
                            end
                        catch
                            hParentController.ErrorDialog=...
                            errordlg([desc,' must be a numeric value greater than zero.'],'Invalid Time-out Value','modal');
                            hObj.(widgetName)=hObj.(['old',widgetName]);
                        end


                        function ProfileGenCode_callback(hObj,hDlg,tag,action)
                            val=hDlg.getWidgetValue(tag);
                            if val
                                setProp(hObj,'exportIDEObj',OnOff(val));
                            end



                            function overrunNotificationFcn_callback(hObj,hDlg,tag,action)
                                hSrc=hObj.getSourceObject;
                                hConfigSet=hSrc.getConfigSet;
                                if~isempty(hConfigSet)
                                    hParentController=hConfigSet.getDialogController;
                                else
                                    hParentController=hObj;
                                end
                                val=hDlg.getWidgetValue(tag);
                                if~iscvar(val)
                                    hParentController.ErrorDialog=errordlg('Interrupt overrun notification function name is not valid function name.');
                                    hObj.overrunNotificationFcn=hObj.oldoverrunNotificationFcn;
                                else
                                    hObj.oldoverrunNotificationFcn=hObj.overrunNotificationFcn;
                                end



                                function projectOptions_callback(hObj,hDlg,tag,action)
                                    switch hObj.projectOptions
                                    case('Debug')
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.debugCompilerOptions);
                                        setProp(hObj,'compilerOptionsStr',hObj.debugCompilerOptions);
                                        hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),hObj.debugLinkerOptions);
                                        setProp(hObj,'linkerOptionsStr',hObj.debugLinkerOptions);
                                    case('Release')
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.releaseCompilerOptions);
                                        setProp(hObj,'compilerOptionsStr',hObj.releaseCompilerOptions);
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.releaseLinkerOptions);
                                        setProp(hObj,'linkerOptionsStr',hObj.releaseLinkerOptions);
                                    case('Custom')
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.customCompilerOptions);
                                        setProp(hObj,'compilerOptionsStr',hObj.customCompilerOptions);
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.customLinkerOptions);
                                        setProp(hObj,'linkerOptionsStr',hObj.customLinkerOptions);
                                    end



                                    function compilerOptionsStr_callback(hObj,hDlg,tag,action)
                                        str=hDlg.getWidgetValue(addsubtag('compilerOptionsStr'));

                                        if~isempty(str)&&str(1)~=' ',
                                            str=[' ',str];
                                        end
                                        hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),str);
                                        setProp(hObj,'compilerOptionsStr',str);
                                        switch hObj.projectOptions
                                        case('Debug')
                                            hObj.debugCompilerOptions=str;
                                        case('Release')
                                            hObj.releaseCompilerOptions=str;
                                        case('Custom')
                                            hObj.customCompilerOptions=str;
                                        end



                                        function linkerOptionsStr_callback(hObj,hDlg,tag,action)
                                            str=hDlg.getWidgetValue(addsubtag('linkerOptionsStr'));

                                            if~isempty(str)&&str(1)~=' ',
                                                str=[' ',str];
                                            end
                                            hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),str);
                                            setProp(hObj,'linkerOptionsStr',str);
                                            switch hObj.projectOptions
                                            case('Debug')
                                                hObj.debugLinkerOptions=str;
                                            case('Release')
                                                hObj.releaseLinkerOptions=str;
                                            case('Custom')
                                                hObj.customLinkerOptions=str;
                                            end



                                            function getCompilerOptions_callback(hObj,hDlg,tag,action)
                                                [boardNum,procNum]=getTgtPref('getBoardProcNums',bdroot);
                                                cs=hObj.createIDEobject(boardNum,procNum);
                                                a=cs.getbuildopt;
                                                hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),a(4).optstring);
                                                setProp(hObj,'compilerOptionsStr',a(4).optstring);
                                                compilerOptionsStr_callback(hObj,hDlg,tag,action);



                                                function resetCompilerOptions_callback(hObj,hDlg,tag,action)
                                                    switch hObj.projectOptions
                                                    case('Debug')
                                                        setProp(hObj,'compilerOptionsStr','-g -d"_DEBUG"');
                                                    case('Release')
                                                        setProp(hObj,'compilerOptionsStr','-o2');
                                                    end
                                                    compilerOptionsStr_callback(hObj,hDlg,tag,action);



                                                    function getLinkerOptions_callback(hObj,hDlg,tag,action)
                                                        [boardNum,procNum]=getTgtPref('getBoardProcNums',bdroot);
                                                        cs=hObj.createIDEobject(boardNum,procNum);
                                                        a=cs.getbuildopt;
                                                        hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),a(1).optstring);
                                                        setProp(hObj,'linkerOptionsStr',a(1).optstring);
                                                        linkerOptionsStr_callback(hObj,hDlg,tag,action);



                                                        function resetLinkerOptions_callback(hObj,hDlg,tag,action)
                                                            setProp(hObj,'linkerOptionsStr','');
                                                            linkerOptionsStr_callback(hObj,hDlg,tag,action);



                                                            function buildAction_callback(hObj,hDlg,tag,action)
                                                                OptionsToBeUnchecked={};
                                                                switch(hObj.buildAction)
                                                                case 'Archive_library'
                                                                    OptionsToBeUnchecked={'ProfileGenCode'};
                                                                end

                                                                for k=1:length(OptionsToBeUnchecked)
                                                                    hDlg.setWidgetValue(addsubtag(OptionsToBeUnchecked{k}),false);
                                                                    setProp(hObj,OptionsToBeUnchecked{k},'off');
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
