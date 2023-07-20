classdef CreatorDialog<handle




    properties(Hidden)
        ModelName='';
        ParentModel='';
        Input='';
        ReportGenLicense=false;
        TopLevelEntry=false;
        paramListSource=[];
    end

    properties(Access=private)
        IsCodeInterfaceFeatureAvailable=false;
        IsAUTOSARModel=false;
    end

    properties(Hidden,Transient)

        hModelCloseListener;
        hiddenFigure;


        isSimEncrypted=false;
        isRTWEncrypted=false;
        isViewEncrypted=false;
        isHDLEncrypted=false;


        testCreator;
    end

    methods







        function obj=CreatorDialog(input)
            narginchk(1,1);



            obj.ReportGenLicense=builtin('license','test','Simulink_Report_Gen');

            obj.Input=input;
            if(ishandle(input))
                object=get_param(input,'Object');
                name=object.getFullName;
                clear('object');
            elseif(ischar(input))
                name=input;
            else
                DAStudio.error('Simulink:protectedModel:protectModelFirstArgStringOrHandle');
            end

            if strcmp(get_param(input,'Type'),'block_diagram')
                assert(bdIsLoaded(input),...
                'Input to CreatorDialog was not a model');

                obj.TopLevelEntry=true;
                obj.ParentModel=name;
                obj.ModelName=name;
            elseif strcmp(get_param(input,'Type'),'block')&&...
                strcmp(get_param(input,'BlockType'),'ModelReference')

                obj.TopLevelEntry=false;
                obj.ParentModel=bdroot(name);
                obj.ModelName=get_param(name,'ModelName');
            else
                assert(false,['Unrecognized input type ',input]);
            end


            if~bdIsLoaded(obj.ModelName)
                load_system(obj.ModelName);
                closeModelOnCleanup=onCleanup(@()close_system(obj.ModelName,0));
            end
            obj.IsAUTOSARModel=strcmp(get_param(obj.ModelName,'AutosarCompliant'),'on');



            if(strcmpi(get_param(obj.ModelName,'SimulinkSubdomain'),'Architecture'))
                DAStudio.error('Simulink:protectedModel:cannotProtectSystemComposerModel',obj.ModelName);
            end


            obj.IsCodeInterfaceFeatureAvailable=...
            Simulink.ModelReference.ProtectedModel.isCodeInterfaceFeatureAvailable...
            (obj.ModelName);


            loadParameterList(obj);
        end


        out=getDialogSchema(obj)






        function browseReportLocation(~,dlg)
            currentPath=dlg.getWidgetValue('protectedMdl_PackagePath');
            if isempty(currentPath)
                currentPath=pwd;
            end

            pathName=uigetdir(currentPath,DAStudio.message('Simulink:protectedModel:ProtectedModelBrowseDlgTitle'));

            if pathName~=0
                dlg.setWidgetValue('protectedMdl_PackagePath',pathName);
            end
        end



        function help(~)
            try
                helpview([docroot,'/toolbox/rtw/helptargets.map'],'generate_protected_model');
            catch ME
                errordlg(ME.message);
            end
        end



        function cancel(~,dlg)
            delete(dlg);
        end

        function pmCreator=checkAndConfigure(obj,dlg)

            obj.checkAndAssignPasswords(dlg);


            obj.checkCurrentOptionsGUI(dlg);


            if slsvTestingHook('ProtectedModelTestProgressStatus')==0
                pmCreator=Simulink.ModelReference.ProtectedModel.Creator(obj.Input,true);
            else
                pmCreator=obj.testCreator;
            end
            obj.configureCreator(pmCreator,dlg);
        end



        function generate(obj,dlg)

            stageName=DAStudio.message('Simulink:protectedModel:ProtectedModelCreationMessageViewerStageName');
            stageObj=Simulink.output.Stage(stageName,'ModelName',obj.ParentModel,'UIMode',true);%#ok<NASGU>
            try

                pmCreator=obj.checkAndConfigure(dlg);


                dlg.apply;
                delete(dlg);
                pmCreator.protect();


                obj.refreshBlocks();
            catch me
                Simulink.output.error(me);
            end
        end




        function refreshBlocks(obj)
            if~obj.TopLevelEntry&&...
                isequal(get_param(obj.Input,'BlockType'),'ModelReference')




                oc=onCleanup(@()set_param(obj.ParentModel,'ProtectedModelCreator',{}));
                set_param(obj.ParentModel,'ProtectedModelCreator',obj);

                blockObj=get_param(obj.ParentModel,'Object');
                try




                    warnStatus=warning('query','Simulink:protectedModel:protectedModelNoExtensionButLoadedError');
                    warnState=warnStatus.state;
                    oc2=onCleanup(@()warning(warnState,'Simulink:protectedModel:protectedModelNoExtensionButLoadedError'));
                    warning('off','Simulink:protectedModel:protectedModelNoExtensionButLoadedError');

                    blockObj.refreshModelBlocks;
                catch me



                    if~strcmp(me.identifier,'Simulink:protectedModel:unableToFindProtectedModelFile')
                        rethrow(me);
                    end
                end
            end
        end

        function[simSupport,cgSupport,viewSupport,hdlSupport,...
            cgCodeInterface,packageContents,...
            createHarness,zipPath,projectName,tunableParams]=getValuesFromCreatorDialog(obj,dlg)
            cgSupport=false;
            viewSupport=false;
            hdlSupport=false;
            cgCodeInterface=false;

            simSupport=dlg.getWidgetValue('protectedMdl_SimulationOnly');
            zipPath=dlg.getWidgetValue('protectedMdl_PackagePath');
            createHarness=dlg.getWidgetValue('protectedMdl_CreateHarness');
            createProject=dlg.getWidgetValue('protectedMdl_SaveOption');
            projectName='';
            if(createProject)
                projectName=dlg.getWidgetValue('protectedMdl_ProjectName');
            end
            if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled
                cgSupport=dlg.getWidgetValue('protectedMdl_CodeGenSupport');
            end
            if Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                hdlSupport=dlg.getWidgetValue('protectedMdl_HDLCodeGenSupport');
            end
            if Simulink.ModelReference.ProtectedModel.isWebviewFeatureEnabled(obj.ReportGenLicense)
                viewSupport=dlg.getWidgetValue('protectedMdl_ProtectedModelWebview');
            end
            packageContents=dlg.getWidgetValue('protectedMdl_ProtectedModelContents');
            if obj.IsCodeInterfaceFeatureAvailable
                cgCodeInterface=dlg.getWidgetValue('protectedMdl_ProtectedModelCodeInterface');
            end
            tunableParams={};
            if slfeature('ProtectedModelTunableParameters')>1

                tunableParams=obj.getTunableParameterTable(dlg);
            end

        end



        function configureCreator(obj,creator,dlg)
            [simSupport,cgSupport,viewSupport,hdlSupport,cgCodeInterface,packageContents,createHarness,zipPath,projectName,tunableParams]...
            =getValuesFromCreatorDialog(obj,dlg);


            if viewSupport&&~(cgSupport||simSupport||hdlSupport)



                creator.enableSupportForViewOnly();
                creator.disableReport();
            elseif cgSupport&&hdlSupport&&simSupport
                creator.addSupportForCodegen();
                creator.addSupportForHDLCodegen();
                creator.enableReport();


                if obj.IsCodeInterfaceFeatureAvailable
                    if cgCodeInterface==0
                        cgCodeInterfaceType='Model reference';
                    else
                        assert((cgCodeInterface==1),...
                        'Unexpected code interface type %d',cgCodeInterface);
                        cgCodeInterfaceType='Top model';
                    end
                    creator.setCodeInterface(cgCodeInterfaceType);
                end

                if packageContents==0
                    creator.enablePackagingBinariesOnly();
                elseif packageContents==1
                    creator.enablePackagingAllSourceCode();
                    creator.setObfuscation(true);
                else
                    creator.enablePackagingAllSourceCode();
                    creator.setObfuscation(false);
                end

                creator.enablePackagingAllHDLCode();
            elseif cgSupport&&simSupport
                creator.addSupportForCodegen();
                creator.enableReport();


                if obj.IsCodeInterfaceFeatureAvailable
                    if cgCodeInterface==0
                        cgCodeInterfaceType='Model reference';
                    else
                        assert((cgCodeInterface==1),...
                        'Unexpected code interface type %d',cgCodeInterface);
                        cgCodeInterfaceType='Top model';
                    end
                    creator.setCodeInterface(cgCodeInterfaceType);
                end

                if packageContents==0
                    creator.enablePackagingBinariesOnly();
                elseif packageContents==1
                    creator.enablePackagingAllSourceCode();
                    creator.setObfuscation(true);
                else
                    creator.enablePackagingAllSourceCode();
                    creator.setObfuscation(false);
                end
            elseif~cgSupport&&~hdlSupport&&simSupport


                creator.enableSupportForAccel();
                creator.setObfuscation(true);
                creator.enablePackagingBinariesOnly();
                creator.enableReport();
            elseif hdlSupport&&simSupport
                creator.addSupportForHDLCodegen();
                creator.enableReport();


                creator.enablePackagingAllHDLCode();
            else

                assert(false,'Cannot configure the protected model due to invalid dialog options');
            end



            if viewSupport
                creator.enableSupportForView();
            end


            creator.setCreateHarness(createHarness);


            if(~isempty(projectName))
                creator.setCreateProject(true);
                creator.setProjectName(projectName);
            end



            creator.setPackagePath(zipPath);


            if obj.isSimEncrypted||obj.isRTWEncrypted||obj.isViewEncrypted||obj.isHDLEncrypted
                creator.enableEncryption;
            end

            if slfeature('ProtectedModelTunableParameters')>1
                creator.setTunableParameters(tunableParams);
            end


            creator.parentModel=obj.ParentModel;


            creator.Input=obj.Input;
        end

        function checkCurrentOptionsGUI(obj,dlg)
            cgSupport=false;
            hdlSupport=false;
            simSupport=dlg.getWidgetValue('protectedMdl_SimulationOnly');
            if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled
                cgSupport=dlg.getWidgetValue('protectedMdl_CodeGenSupport');
            end
            if Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                hdlSupport=dlg.getWidgetValue('protectedMdl_HDLCodeGenSupport');
            end

            if Simulink.ModelReference.ProtectedModel.isWebviewFeatureEnabled(obj.ReportGenLicense)
                viewSupport=dlg.getWidgetValue('protectedMdl_ProtectedModelWebview');

                if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled||...
                    Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                    if~(viewSupport||cgSupport||simSupport||hdlSupport)
                        DAStudio.error('Simulink:protectedModel:ProtectedModelNoOptionsSelectedError');
                    end
                else
                    if~(viewSupport||simSupport)
                        DAStudio.error('Simulink:protectedModel:ProtectedModelNoOptionsSelectedError');
                    end
                end
            else
                if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled||...
                    Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                    if~(cgSupport||simSupport||hdlSupport)
                        DAStudio.error('Simulink:protectedModel:ProtectedModelNoOptionsSelectedError');
                    end
                else
                    if~simSupport
                        DAStudio.error('Simulink:protectedModel:ProtectedModelNoOptionsSelectedError');
                    end
                end
            end

            if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled
                assert(~((cgSupport==true)&&(simSupport==false)),'Code generation requires that simulation be selected');
            end

            if Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                assert(~((hdlSupport==true)&&(simSupport==false)),'HDL Code generation requires that simulation be selected');
            end

            if isempty(dlg.getWidgetValue('protectedMdl_PackagePath'))
                DAStudio.error('Simulink:protectedModel:ProtectedModelEmptyOutputDirectory');
            end


            if(slfeature('ProtectedModelDirectSimulation')>1)
                createProject=dlg.getWidgetValue('protectedMdl_SaveOption');
                if(createProject&&isempty(dlg.getWidgetValue('protectedMdl_ProjectName')))
                    DAStudio.error('Simulink:protectedModel:ProtectedModelEmptyProjectName');
                end
            end
        end


        function checkAndAssignPasswords(obj,dlg)
            import Simulink.ModelReference.ProtectedModel.*;
            [sim,cg,view,hdl]=obj.checkPasswordsAgainstVerifyPasswords(dlg);

            obj.isSimEncrypted=false;
            obj.isRTWEncrypted=false;
            obj.isViewEncrypted=false;
            obj.isHDLEncrypted=false;


            if sim.enabled&&~isempty(sim.password)
                setPasswordForSimulation(obj.ModelName,sim.password);
                obj.isSimEncrypted=true;
            end
            if cg.enabled&&~isempty(cg.password)
                setPasswordForCodeGeneration(obj.ModelName,cg.password);
                obj.isRTWEncrypted=true;
            end
            if view.enabled&&~isempty(view.password)
                setPasswordForView(obj.ModelName,view.password);
                obj.isViewEncrypted=true;
            end
            if hdl.enabled&&~isempty(hdl.password)
                setPasswordForHDLCodeGeneration(obj.ModelName,hdl.password);
                obj.isHDLEncrypted=true;
            end
        end

        function installModelCloseListener(obj,dlg)


            blkDiagram=get_param(obj.ParentModel,'Object');
            obj.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',...
            @(src,evt)Simulink.ModelReference.ProtectedModel.Creator.removeDlg(dlg));

        end



        function[sim,cg,view,hdl]=checkPasswordsAgainstVerifyPasswords(obj,dlg)


            erroringCategories='';

            view.enabled=false;
            cg.enabled=false;
            hdl.enabled=false;

            view.password='';
            cg.password='';
            sim.password='';
            hdl.password='';

            sim.enabled=dlg.getWidgetValue('protectedMdl_SimulationOnly');



            if Simulink.ModelReference.ProtectedModel.isWebviewFeatureEnabled(obj.ReportGenLicense)
                viewPW=dlg.getWidgetValue('protectedMdl_ViewPassword');
                view.enabled=dlg.getWidgetValue('protectedMdl_ProtectedModelWebview');
                viewPWVerify=dlg.getWidgetValue('protectedMdl_ViewPasswordVerify');
                if~strcmp(viewPW,viewPWVerify)&&view.enabled
                    erroringCategories=sprintf([erroringCategories,'\n',DAStudio.message('Simulink:protectedModel:ProtectedModelViewLbl')]);
                else
                    view.password=viewPW;
                end
            end


            simPW=dlg.getWidgetValue('protectedMdl_SimPassword');
            simPWVerify=dlg.getWidgetValue('protectedMdl_SimPasswordVerify');
            if~strcmp(simPW,simPWVerify)&&sim.enabled
                erroringCategories=sprintf([erroringCategories,'\n',DAStudio.message('Simulink:protectedModel:ProtectedModelSimulationLbl')]);
            else
                sim.password=simPW;
            end



            if Simulink.ModelReference.ProtectedModel.isCodeGenFeatureEnabled
                cg.enabled=dlg.getWidgetValue('protectedMdl_CodeGenSupport');
                cgPW=dlg.getWidgetValue('protectedMdl_CodegenPassword');
                cgPWVerify=dlg.getWidgetValue('protectedMdl_CodegenPasswordVerify');
                if~strcmp(cgPW,cgPWVerify)&&cg.enabled
                    erroringCategories=sprintf([erroringCategories,'\n',DAStudio.message('Simulink:protectedModel:ProtectedModelCodeGenerationLbl')]);
                else
                    cg.password=cgPW;
                end
            end



            if Simulink.ModelReference.ProtectedModel.isHDLCodeGenFeatureEnabled
                hdl.enabled=dlg.getWidgetValue('protectedMdl_HDLCodeGenSupport');
                hdlPW=dlg.getWidgetValue('protectedMdl_HDLCodegenPassword');
                hdlPWVerify=dlg.getWidgetValue('protectedMdl_HDLCodegenPasswordVerify');
                if~strcmp(hdlPW,hdlPWVerify)&&hdl.enabled
                    erroringCategories=sprintf([erroringCategories,'\n',DAStudio.message('Simulink:protectedModel:ProtectedModelHDLCodeGenerationLbl')]);
                else
                    hdl.password=hdlPW;
                end
            end


            if~isempty(erroringCategories)
                DAStudio.error('Simulink:protectedModel:EncryptPasswordMismatchError',erroringCategories);
            end
        end

        function parameterSelectionHelper(obj,dlg,value)
            if isempty(obj.paramListSource.m_Data)
                return;
            end
            for i=1:length(obj.paramListSource.m_Data)
                obj.paramListSource.m_Data(i).m_Tunable=value;
            end

            spSheet=dlg.getWidgetInterface('protectedMdl_paramList');
            spSheet.update(true);
        end


        function selectAll(obj,dlg)
            obj.parameterSelectionHelper(dlg,1);
        end

        function unselectAll(obj,dlg)
            obj.parameterSelectionHelper(dlg,0);
        end

        function loadParameterList(obj)
            if slfeature('ProtectedModelTunableParameters')>1

                obj.paramListSource=Simulink.ModelReference.ProtectedModel.ParameterSpreadSheetSource(obj);
            end
        end
        function tunableParams=getTunableParameterTable(~,dlg)
            tunableParams={};
            allParams=dlg.getWidgetValue('protectedMdl_paramList');
            for i=1:length(allParams)
                if(allParams{i}.m_Tunable)
                    tunableParams{end+1}=allParams{i}.m_ParamName;
                end
            end
        end


        function updateCodegenSupport(obj,dlg)
            cgsupport=dlg.getWidgetValue('protectedMdl_CodeGenSupport');




            dlg.setEnabled('protectedMdl_ProtectedModelContents',cgsupport);
            if obj.IsCodeInterfaceFeatureAvailable
                dlg.setEnabled('protectedMdl_ProtectedModelCodeInterface',cgsupport);
            end


            dlg.setEnabled('protectedMdl_CodegenPassword',cgsupport);
            dlg.setEnabled('protectedMdl_CodegenPasswordVerify',cgsupport);

            if cgsupport

                dlg.setWidgetValue('protectedMdl_ProtectedModelContents',1);


                dlg.setWidgetValue('protectedMdl_SimulationOnly',true);
                dlg.setEnabled('protectedMdl_SimPassword',true);
                dlg.setEnabled('protectedMdl_SimPasswordVerify',true);
            else

                dlg.setWidgetValue('protectedMdl_ProtectedModelContents',0);
            end
        end


        function updateHDLCodegenSupport(~,dlg)
            hdlcgsupport=dlg.getWidgetValue('protectedMdl_HDLCodeGenSupport');


            dlg.setEnabled('protectedMdl_HDLCodegenPassword',hdlcgsupport);
            dlg.setEnabled('protectedMdl_HDLCodegenPasswordVerify',hdlcgsupport);

            if hdlcgsupport

                dlg.setWidgetValue('protectedMdl_SimulationOnly',true);
                dlg.setEnabled('protectedMdl_SimPassword',true);
                dlg.setEnabled('protectedMdl_SimPasswordVerify',true);
            end
        end


        function updateWebviewSupport(~,dlg)
            viewSupport=dlg.getWidgetValue('protectedMdl_ProtectedModelWebview');
            dlg.setEnabled('protectedMdl_ViewPassword',viewSupport);
            dlg.setEnabled('protectedMdl_ViewPasswordVerify',viewSupport);
        end


        function updateSimulationSupport(obj,dlg)

            simSupport=dlg.getWidgetValue('protectedMdl_SimulationOnly');
            dlg.setEnabled('protectedMdl_SimPassword',simSupport);
            dlg.setEnabled('protectedMdl_SimPasswordVerify',simSupport);
            if~simSupport


                dlg.setWidgetValue('protectedMdl_CodeGenSupport',false);
                dlg.setEnabled('protectedMdl_CodegenPassword',false);
                dlg.setEnabled('protectedMdl_CodegenPasswordVerify',false);
                dlg.setWidgetValue('protectedMdl_ProtectedModelContents',0);
                dlg.setEnabled('protectedMdl_ProtectedModelContents',false);
                if obj.IsCodeInterfaceFeatureAvailable
                    dlg.setEnabled('protectedMdl_ProtectedModelCodeInterface',false);
                end




                dlg.setWidgetValue('protectedMdl_HDLCodeGenSupport',false);
                dlg.setEnabled('protectedMdl_HDLCodegenPassword',false);
                dlg.setEnabled('protectedMdl_HDLCodegenPasswordVerify',false);
            end
        end


        function updateSaveOption(obj,dlg)
            saveOption=dlg.getWidgetValue('protectedMdl_SaveOption');
            dlg.setEnabled('protectedMdl_ProjectName',saveOption);
            dlg.setEnabled('protectedMdl_CreateHarness',~saveOption);
            dlg.setWidgetValue('protectedMdl_CreateHarness',saveOption);
            if(saveOption)
                dlg.setWidgetValue('protectedMdl_ProjectName',[obj.ModelName,'_protected']);
            else
                dlg.setWidgetValue('protectedMdl_ProjectName','');
            end
        end
    end

    methods(Static=true,Hidden=true)



        function removeDlg(dlg)
            if ishandle(dlg)
                dlg.delete;
            end
        end
    end
end


