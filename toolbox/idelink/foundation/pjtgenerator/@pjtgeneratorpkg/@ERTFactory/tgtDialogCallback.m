function tgtDialogCallback(hObj,hDlg,tag,action)














    ObjProp=tag(length('Tag_ConfigSet_Target_')+1:end);


    feval([ObjProp,'_callback'],hObj,hDlg,tag,action);
    EnableApplyButton(hDlg);


    function AdaptorName_callback(hObj,hDlg,tag,action)

        buildAction_callback(hObj,hDlg,tag,action);


        function buildFormat_callback(hObj,hDlg,tag,action)
            OptionsToBeUnchecked={};
            switch hObj.buildFormat
            case('Makefile')
                OptionsToBeUnchecked={'ProfileGenCode'};
            end
            for k=1:length(OptionsToBeUnchecked)
                hDlg.setWidgetValue(addsubtag(OptionsToBeUnchecked{k}),false);
                setProp(hObj,OptionsToBeUnchecked{k},'off');
            end


            buildAction_callback(hObj,hDlg,tag,action);


            function exportIDEObj_callback(hObj,hDlg,tag,~)
                val=hDlg.getWidgetValue(tag);
                setProp(hObj,'exportIDEObj',OnOff(val));



                function ideObjName_callback(hObj,hDlg,tag,~)%#ok<*DEFNU>
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


                    function ideObjTimeout_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                        setNumericWidgetValue(hObj,hDlg,tag,action,'ideObjTimeout','Time-out');


                        function ideObjBuildTimeout_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                            setNumericWidgetValue(hObj,hDlg,tag,action,'ideObjBuildTimeout','Build time-out');


                            function setNumericWidgetValue(hObj,hDlg,tag,~,widgetName,desc)
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
                                catch %#ok<CTCH>
                                    hParentController.ErrorDialog=...
                                    errordlg([desc,' must be a numeric value greater than zero.'],'Invalid Time-out Value','modal');
                                    hObj.(widgetName)=hObj.(['old',widgetName]);
                                end


                                function ProfileGenCode_callback(hObj,hDlg,tag,~)%#ok<DEFNU>
                                    val=hDlg.getWidgetValue(tag);
                                    if val
                                        setProp(hObj,'exportIDEObj',OnOff(val));
                                    end



                                    function overrunNotificationFcn_callback(hObj,hDlg,tag,~)%#ok<DEFNU>
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



                                        function projectOptions_callback(hObj,hDlg,~,~)%#ok<DEFNU>
                                            switch hObj.projectOptions
                                            case('Debug')
                                                hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.debugCompilerOptions);
                                                setProp(hObj,'compilerOptionsStr',hObj.debugCompilerOptions);
                                                hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),hObj.debugLinkerOptions);
                                                setProp(hObj,'linkerOptionsStr',hObj.debugLinkerOptions);
                                            case('Release')
                                                hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.releaseCompilerOptions);
                                                setProp(hObj,'compilerOptionsStr',hObj.releaseCompilerOptions);
                                                hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),hObj.releaseLinkerOptions);
                                                setProp(hObj,'linkerOptionsStr',hObj.releaseLinkerOptions);
                                            case('Custom')
                                                hDlg.setWidgetValue(addsubtag('compilerOptionsStr'),hObj.customCompilerOptions);
                                                setProp(hObj,'compilerOptionsStr',hObj.customCompilerOptions);
                                                hDlg.setWidgetValue(addsubtag('linkerOptionsStr'),hObj.customLinkerOptions);
                                                setProp(hObj,'linkerOptionsStr',hObj.customLinkerOptions);
                                            end


                                            function compilerOptionsStr_callback(hObj,hDlg,~,~)
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



                                                function linkerOptionsStr_callback(hObj,hDlg,~,~)
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



                                                    function getCompilerOptions_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                                                        opt=hObj.ProjectMgr.getIDEBuildOptions(bdroot,hObj.AdaptorName,'compiler');
                                                        if(~isempty(opt))
                                                            setProp(hObj,'compilerOptionsStr',opt);
                                                            compilerOptionsStr_callback(hObj,hDlg,tag,action);
                                                        end


                                                        function resetCompilerOptions_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                                                            opts=hObj.ProjectMgr.getDefaultBuildOptions(hObj.AdaptorName);
                                                            switch hObj.projectOptions
                                                            case('Debug')
                                                                setProp(hObj,'compilerOptionsStr',opts.compiler.debug);
                                                            case('Release')
                                                                setProp(hObj,'compilerOptionsStr',opts.compiler.release);
                                                            case('Custom')
                                                                setProp(hObj,'compilerOptionsStr',opts.compiler.custom);
                                                            end
                                                            compilerOptionsStr_callback(hObj,hDlg,tag,action);



                                                            function getLinkerOptions_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                                                                opt=hObj.ProjectMgr.getIDEBuildOptions(bdroot,hObj.AdaptorName,'linker');
                                                                if(~isempty(opt))
                                                                    setProp(hObj,'linkerOptionsStr',opt);
                                                                    linkerOptionsStr_callback(hObj,hDlg,tag,action);
                                                                end


                                                                function resetLinkerOptions_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                                                                    opts=hObj.ProjectMgr.getDefaultBuildOptions(hObj.AdaptorName);
                                                                    switch hObj.projectOptions
                                                                    case('Debug')
                                                                        setProp(hObj,'linkerOptionsStr',opts.linker.debug);
                                                                    case('Release')
                                                                        setProp(hObj,'linkerOptionsStr',opts.linker.release);
                                                                    case('Custom')
                                                                        setProp(hObj,'linkerOptionsStr',opts.linker.custom);
                                                                    end
                                                                    compilerOptionsStr_callback(hObj,hDlg,tag,action);



                                                                    function buildAction_callback(hObj,hDlg,tag,action)%#ok<DEFNU>
                                                                        OptionsToBeChecked={};
                                                                        OptionsToBeUnchecked={};


                                                                        pilval=false;

                                                                        switch(hObj.buildAction)
                                                                        case 'Archive_library'
                                                                            OptionsToBeUnchecked={'ProfileGenCode'};
                                                                        case 'Create_Processor_In_the_Loop_project'
                                                                            switch(hObj.buildFormat)
                                                                            case 'Makefile'
                                                                                setProp(hObj,'buildAction',...
                                                                                hObj.ProjectMgr.getDefaultBuildAction(hObj.AdaptorName,hObj.buildFormat));
                                                                            case 'Project'
                                                                                setProp(hObj,'configPILBlockAction','Create_PIL_block_build_and_download')
                                                                                OptionsToBeUnchecked={'ProfileGenCode'};
                                                                                OptionsToBeChecked={'exportIDEObj'};
                                                                                pilval=true;
                                                                            end
                                                                        end

                                                                        configurePILSettings(hObj,pilval);
                                                                        setProp(hObj,'configurePIL',OnOff(pilval));

                                                                        for k=1:length(OptionsToBeUnchecked)
                                                                            hDlg.setWidgetValue(addsubtag(OptionsToBeUnchecked{k}),false);
                                                                            setProp(hObj,OptionsToBeUnchecked{k},'off');
                                                                        end
                                                                        for k=1:length(OptionsToBeChecked)
                                                                            hDlg.setWidgetValue(addsubtag(OptionsToBeChecked{k}),false);
                                                                            setProp(hObj,OptionsToBeChecked{k},'on');
                                                                        end


                                                                        linkerOptionsStr_callback(hObj,hDlg,tag,action);
                                                                        compilerOptionsStr_callback(hObj,hDlg,tag,action);



                                                                        projectOptions_callback(hObj,hDlg,tag,action);







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


