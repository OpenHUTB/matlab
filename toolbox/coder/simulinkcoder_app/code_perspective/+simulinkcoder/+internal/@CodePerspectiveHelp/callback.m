function callback(obj,msg)




    id=msg.id;

    switch id
    case 'runQuickStart'
        src=simulinkcoder.internal.util.getSource;
        action=msg.action;
        mdl=src.modelH;

        if strcmp(action,'Help_SimulinkCoder')

            simulinkcoder.internal.wizard.slcoderWizard(mdl,'Start');
        elseif strcmp(action,'Help_EmbeddedCoder')

            coder.internal.wizard.slcoderWizard(mdl,'Start');
        elseif strcmp(action,'Help_AUTOSAR')

        end

    case 'seehow'
        gif=msg.action;
        overlay=obj.overlay;
        overlay.fg=gif;
        overlay.show;

    case 'readmore'
        tag=msg.action;
        target=msg.target;



        if startsWith(target,'autosar')
            map=fullfile(docroot,'autosar','helptargets.map');
        elseif strcmp(target,'grt')
            map=fullfile(docroot,'rtw','helptargets.map');
        else
            map=fullfile(docroot,'ecoder','helptargets.map');
        end

        try
            helpview(map,tag);
        catch e
            disp(e);
        end

    case 'gothere'
        cb=msg.action;
        fn=str2func(cb);
        src=simulinkcoder.internal.util.getSource;
        fn(src);

    end


    function ConfigSetCodeGen(src)%#ok<*DEFNU>
        cs=getActiveConfigSet(src.modelH);
        configset.showParameterGroup(cs,{'CodeGeneration'});

        function ConfigSetReusable(src)
            cs=getActiveConfigSet(src.modelH);
            configset.highlightParameter(cs,'CodeInterfacePackaging');

            function openCodeMappingInternalData(src)
                openCodeMappingDefaultData(src);

                function openCodeMappingInterfaceData(src)

                    openCodeMappingDefaultData(src);

                    function openCodeMappingDefaultData(src)
                        cp=simulinkcoder.internal.CodePerspective.getInstance;
                        task=cp.getTask('CodeMapping');
                        task.show(src.studio);
                        DataView.showModelData(src.studio,'CodeProperties','DataDefaults',...
                        'Simulink:studio:DataViewPerspective_CodeGen');

                        function openCodeMappingDefaultFunction(src)
                            cp=simulinkcoder.internal.CodePerspective.getInstance;
                            task=cp.getTask('CodeMapping');
                            task.show(src.studio);
                            DataView.showModelData(src.studio,'CodeProperties','FunctionsDefaults',...
                            'Simulink:studio:DataViewPerspective_CodeGen');


                            function goto_cpp_interface_data(src)

                                cs=getActiveConfigSet(src.modelH);
                                configset.highlightParameter(cs,'GenerateExternalIOAccessMethods');

                                function goto_cpp_interface_functions(src)

                                    cs=getActiveConfigSet(src.modelH);
                                    configset.highlightParameter(cs,'CPPClassCustomize');


                                    function goto_autosar_config_slmap_rootio(src)

                                        cp=simulinkcoder.internal.CodePerspective.getInstance;
                                        task=cp.getTask('CodeMapping');
                                        task.show(src.studio);
                                        DataView.showModelData(src.studio,'CodeProperties','Inports',...
                                        'Simulink:studio:DataViewPerspective_CodeGen');

                                        function goto_autosar_config_slmap_slfunctions(src)



                                            cp=simulinkcoder.internal.CodePerspective.getInstance;
                                            task=cp.getTask('CodeMapping');
                                            task.show(src.studio);
                                            DataView.showModelData(src.studio,'CodeProperties','FunctionCallers',...
                                            'Simulink:studio:DataViewPerspective_CodeGen');

                                            function goto_autosar_config_slmap_epfunctions(src)



                                                cp=simulinkcoder.internal.CodePerspective.getInstance;
                                                task=cp.getTask('CodeMapping');
                                                task.show(src.studio);
                                                DataView.showModelData(src.studio,'CodeProperties','EntryPointFunctions',...
                                                'Simulink:studio:DataViewPerspective_CodeGen');

                                                function goto_autosar_config_slmap_datatransfers(src)



                                                    cp=simulinkcoder.internal.CodePerspective.getInstance;
                                                    task=cp.getTask('CodeMapping');
                                                    task.show(src.studio);
                                                    DataView.showModelData(src.studio,'CodeProperties','DataTransfers',...
                                                    'Simulink:studio:DataViewPerspective_CodeGen');

                                                    function goto_autosar_config_codgen(src)



                                                        cs=getActiveConfigSet(src.modelH);
                                                        configset.highlightParameter(cs,'AutosarSchemaVersion');

                                                        function goto_autosar_config_props_xmloptions(src)

                                                            if autosarinstalled()
                                                                autosar_ui_launch(src.modelH);
                                                                explorer=autosar.ui.utils.findExplorerForModel(src.modelH);
                                                                if~isempty(explorer)
                                                                    autosar.ui.utils.selectTargetTreeElement(explorer.TraversedRoot,...
                                                                    autosar.ui.metamodel.PackageString.Preferences);
                                                                end
                                                            end


