classdef CloneDetectionCtx<dig.CustomContext




    properties(SetObservable=true)
        enableIncludeLibs;
        enableExcludeComponents;
        enableRefactor;
        enableDetect;
        enableVerify;
        showVerify;
        parameterThreshold;
        enableParameterThreshold;
        enableReplaceWithSSRef;
        enableMatchPatternsFromLib;
        isReplaceExactCloneWithSubsysRef;
        ui;
        showHelpPerspective;
        showResultsPerspective;
        showPropertiesPerspective;
        ignoreSignalName;
        ignoreBlockProperty;
        origTypeChain;
        enableClonesAnywhere;
        RegionSize;
        regionSizeEnable;
        CloneGroupSize;
        cloneGroupSizeEnable;
    end

    methods
        function obj=CloneDetectionCtx(app,cbinfo)
            obj@dig.CustomContext(app);
            obj.origTypeChain=obj.TypeChain;


            if isempty(cbinfo.studio.App.getPinnedSystem('selectSystemCloneDetectionAction'))
                cbinfo.studio.App.insertPinnedSystem('selectSystemCloneDetectionAction',...
                cbinfo.model,Simulink.ID.getSID(cbinfo.model.handle));
            end

            obj.enableIncludeLibs=false;
            obj.enableExcludeComponents=false;
            obj.showHelpPerspective=false;
            obj.showResultsPerspective=false;
            obj.showPropertiesPerspective=false;
            sysHandle=SLStudio.Utils.getModelName(cbinfo);

            if~license('test','sl_verification_validation')
                DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseFail');
            end

            if~exist(['m2m_',get_param(sysHandle,'Name')],'dir')
                obj.ui=CloneDetectionUI.CloneDetectionUI(sysHandle);
                obj.ui.model=get_param(sysHandle,'handle');
                obj.ui.ddgBottom.model=obj.ui.model;
                obj.ui.toolstripCtx=obj;
            else
                modelDir=dir(['m2m_',sysHandle,'/*.mat']);
                dates=[modelDir.datenum];
                if isempty(dates)
                    obj.ui=CloneDetectionUI.CloneDetectionUI(sysHandle);
                    obj.ui.model=get_param(sysHandle,'handle');
                    obj.ui.ddgBottom.model=obj.ui.model;
                    obj.ui.toolstripCtx=obj;
                else
                    [~,newestIndex]=max(dates);
                    latestBackUpFile=modelDir(newestIndex);
                    if~isempty(get_param(sysHandle,'CloneDetectionUIObj'))
                        obj.ui=get_param(sysHandle,'CloneDetectionUIObj');
                    else
                        loadedObject=load(['m2m_',sysHandle,'/',latestBackUpFile.name]);
                        obj.ui=loadedObject.updatedObj;
                    end

                    if isa(obj.ui,'Simulink.CloneDetection.internal.ClonesData')
                        cloneDetectionUIObject=CloneDetectionUI.CloneDetectionUI(sysHandle);
                        obj.ui=clone_detection_app.internal.apiToGUIClonesDataAdapter(...
                        cloneDetectionUIObject,obj.ui);
                        set_param(sysHandle,'CloneDetectionUIObj',obj.ui);
                    end

                    obj.ui.model=get_param(sysHandle,'handle');
                    obj.ui.ddgBottom.model=obj.ui.model;
                    obj.ui.ddgRight.model=obj.ui.model;
                    obj.ui.toolstripCtx=obj;
                    if~isa(obj.ui.m2mObj,'slEnginePir.acrossModelGraphicalCloneDetection')
                        if~isempty(obj.ui.m2mObj.refModels)
                            CloneDetectionUI.internal.util.loadAllModelRefs(obj.ui.m2mObj.refModels);
                        end
                    end
                    if~isempty(obj.ui.m2mObj.cloneresult)
                        CloneDetectionUI.internal.util.hiliteAllClones(obj.ui.refactorButtonEnable,...
                        length(obj.ui.m2mObj.cloneresult.similar),obj.ui.blockPathCategoryMap,obj.ui.colorCodes);
                    end

                    obj.showResultsPerspective=true;
                    obj.showPropertiesPerspective=true;
                end
            end


            obj.showVerify=license('test','Simulink_Test');


            obj.enableRefactor=obj.ui.refactorButtonEnable;
            obj.enableDetect=true;
            obj.enableVerify=obj.ui.compareModelButtonEnable;
            obj.enableClonesAnywhere=obj.ui.enableClonesAnywhere;
            obj.RegionSize=obj.ui.regionSize;
            obj.regionSizeEnable=obj.ui.regionSizeEnable;
            obj.CloneGroupSize=obj.ui.cloneGroupSize;
            obj.cloneGroupSizeEnable=obj.ui.cloneGroupSizeEnable;
            obj.parameterThreshold=obj.ui.parameterThreshold;
            obj.ignoreSignalName=obj.ui.ignoreSignalName;
            obj.ignoreBlockProperty=obj.ui.ignoreBlockProperty;
            obj.enableParameterThreshold=~obj.ui.isReplaceExactCloneWithSubsysRef;
            obj.enableReplaceWithSSRef=isempty(obj.ui.libraryList);
            obj.enableMatchPatternsFromLib=~obj.ui.isReplaceExactCloneWithSubsysRef;
            obj.isReplaceExactCloneWithSubsysRef=obj.ui.isReplaceExactCloneWithSubsysRef;
            if obj.showHelpPerspective
                CloneDetectionUI.internal.util.showEmbedded(obj.ui.ddgHelp,'Left','Tabbed');
            end
            if obj.showPropertiesPerspective
                CloneDetectionUI.internal.util.showEmbedded(obj.ui.ddgRight,'Right','Tabbed');
            end
            if obj.showResultsPerspective
                CloneDetectionUI.internal.util.showEmbedded(obj.ui.ddgBottom,'Bottom','Tabbed');
            end
            set_param(sysHandle,'CloneDetectionUIObj',obj.ui);
            if isempty(obj.RegionSize)
                obj.RegionSize='2';
            end
            if isempty(obj.CloneGroupSize)
                obj.CloneGroupSize='2';
            end
            set_param(sysHandle,'CloneDetectionUIObj',obj.ui);
        end
    end
end
