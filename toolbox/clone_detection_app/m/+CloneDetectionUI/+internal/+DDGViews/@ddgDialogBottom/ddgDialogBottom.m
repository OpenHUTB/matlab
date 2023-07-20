classdef ddgDialogBottom<handle








    properties(Constant)
        id=DAStudio.message('sl_pir_cpp:creator:ddgBottomTitle');
        title=DAStudio.message('sl_pir_cpp:creator:ddgBottomTitle');
        comp='GLUE2:DDG Component'
        defaultParameterThreshold='50';
    end
    properties
        cloneUIObj;
        model;
        result='';
        status='';
    end

    methods(Access=public)


        dlgStruct=getDialogSchema(this);
        browseNewLibFile(this);
        highlightAllClones(this);


        function this=ddgDialogBottom(cloneUIObj)
            this.cloneUIObj=cloneUIObj;
            this.model=cloneUIObj.model;
        end


        function includeLibrariesCallback(this)
            instance=CloneDetectionUI.internal.util.findExistingDlg(get_param(this.cloneUIObj.model,'Name'),'AddLibrary');
            if~isempty(instance)
                return
            end
            instance=CloneDetectionUI.internal.DDGViews.AddLibrary(this.cloneUIObj);
            CloneDetectionUI.internal.util.show(instance);
        end


        function colorSettingsCallBack(this)
            instance=CloneDetectionUI.internal.util.findExistingDlg(get_param(this.cloneUIObj.model,'Name'),'ColorSelection');
            if~isempty(instance)
                return
            end
            instance=CloneDetectionUI.internal.DDGViews.ColorSelection(this.cloneUIObj);
            CloneDetectionUI.internal.util.show(instance);
        end


        function refactorOptionsCallBack(this)
            instance=CloneDetectionUI.internal.util.findExistingDlg(get_param(this.cloneUIObj.model,'Name'),'RefactorOptions');
            if~isempty(instance)
                return
            end
            instance=CloneDetectionUI.internal.DDGViews.RefactorOptions(this.cloneUIObj);
            CloneDetectionUI.internal.util.show(instance);
        end


        function saveParameterThreshold(this)
            dlgHandle=DAStudio.ToolRoot.getOpenDialogs(this);
            paramThreshold=dlgHandle.getWidgetValue('parameterThreshold');
            threshold=str2double(paramThreshold);
            if isnan(threshold)||threshold<0||threshold>realmax
                DAStudio.error('sl_pir_cpp:creator:IllegalNumber',num2str(realmax));
            end
            if isempty(paramThreshold)
                this.cloneUIObj.setParameterThreshold(this.defaultParameterThreshold);
            else
                this.cloneUIObj.setParameterThreshold(paramThreshold);
            end


            if~isempty(this.cloneUIObj.objectFile)
                if~exist(this.cloneUIObj.backUpPath,'dir')
                    mkdir(this.cloneUIObj.backUpPath);
                    this.cloneUIObj.historyVersions=[];
                end
                updatedObj=this.cloneUIObj;
                save(this.cloneUIObj.objectFile,'updatedObj');
            end

        end


        function updateRefactorLibFileName(this)
            dlgHandle=DAStudio.ToolRoot.getOpenDialogs(this);
            fileName=dlgHandle.getWidgetValue('libraryNameTag');
            if~CloneDetectionUI.internal.DDGViews.AddLibrary.checkFileName(fileName)
                this.cloneUIObj.refactoredClonesLibFileName='newLibraryFile';
                dlgHandle.setWidgetValue('libraryNameTag','newLibraryFile');
            else
                this.cloneUIObj.refactoredClonesLibFileName=fileName;
            end


            if~isempty(this.cloneUIObj.objectFile)
                if~exist(this.cloneUIObj.backUpPath,'dir')
                    mkdir(this.cloneUIObj.backUpPath);
                    this.cloneUIObj.historyVersions=[];
                end
                updatedObj=this.cloneUIObj;
                save(this.cloneUIObj.objectFile,'updatedObj');
            end
        end



        function exclusionsEditorCallback(this)
            exclusionEditorWindow=CloneDetector.getExclusionEditor(get_param(this.model,'Name'));
            exclusionEditorWindow.open();
        end



        function successFlag=compareModelsCallback(this)
            modelName1=get_param(this.model,'name');
            modelName2=slEnginePir.util.getBackupModelName(this.cloneUIObj.m2mObj.genmodelprefix,modelName1);
            successFlag=true;


            testFile=sltest.testmanager.TestFile([modelName1,'clonedetectionTestFile.txt']);

            testSuites=testFile.getTestSuites;
            testCases=testSuites.getTestCases;


            testFile.convertTestType(sltest.testmanager.TestCaseTypes.Equivalence)


            testCases.setProperty('model',modelName1,'SimulationIndex',1);
            testCases.setProperty('model',modelName2,'SimulationIndex',2);


            testResult=run(testCases);
            if strcmp(testResult.Outcome,'Failed')
                successFlag=false;
            end


            stm.view

        end
    end
end


