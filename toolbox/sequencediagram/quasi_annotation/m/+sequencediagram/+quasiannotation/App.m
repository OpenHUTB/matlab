classdef(Sealed)App<handle

    properties(Access=private)
        ModelManagers=sequencediagram.quasiannotation.internal.ModelManager.empty()
        AnnotationChangedListeners=containers.Map();%#ok<MCHDP> Singleton class so this MLint isn't an issue
SequenceDiagramOpenedListener
    end

    properties(Constant,Access=private)
        SimulinkCallbackId='SequenceDiagramQuasiAnnotation';
        MatFileSuffix='_SequenceDiagramQuasiAnnotations.mat';
        ReqLinkFileSuffix='_SequenceDiagramQuasiAnnotations.slmx'
    end

    methods(Hidden,Static)
        function obj=getInstance()
            mlock;
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=sequencediagram.quasiannotation.App();
            end
            obj=instance;
        end
    end


    methods(Static)

        function add(annotation,modelName,sequenceDiagramName)
            app=sequencediagram.quasiannotation.App.getInstance();
            app.addImpl(annotation,modelName,sequenceDiagramName);
        end


        function remove(annotation)
            app=sequencediagram.quasiannotation.App.getInstance();
            app.removeImpl(annotation);
        end


        function annotations=getAllAnnotations(model,sequenceDiagramName)
            if nargin<2
                sequenceDiagramName=[];
            end

            if nargin<1
                model=[];
            end

            if~isempty(model)
                model=get_param(model,'handle');
            end
            app=sequencediagram.quasiannotation.App.getInstance();
            annotations=app.getAllAnnotationsImpl(model,sequenceDiagramName);
        end


        function sequenceDiagramRenamed(model,oldSequenceDiagramName,newSequenceDiagramName)
            mdlHandle=get_param(model,'handle');
            app=sequencediagram.quasiannotation.App.getInstance();
            app.sequenceDiagramRenamedImpl(mdlHandle,oldSequenceDiagramName,newSequenceDiagramName);
        end


        function sequenceDiagramDeleted(model,sequenceDiagramName)
            mdlHandle=get_param(model,'handle');
            app=sequencediagram.quasiannotation.App.getInstance();
            app.sequenceDiagramDeletedImpl(mdlHandle,sequenceDiagramName);
        end
    end


    methods(Hidden)
        function addBlockDiagramCreatedCallback(obj)
            Simulink.addRootPostCreateCallback(obj.SimulinkCallbackId,@(mdlName)obj.blockDiagramCreated(mdlName));
        end


        function removeBlockDiagramCreatedCallback(obj)
            Simulink.removeRootPostCreateCallback(obj.SimulinkCallbackId);
        end

        function[annotation,modelManager,sequenceDiagramManager]=findAnnotationFromUuid(obj,uuid)
            for modelManager=obj.ModelManagers
                for sequenceDiagramManager=modelManager.SequenceDiagramManagers
                    idx=strcmp([sequenceDiagramManager.Annotations.UUID],uuid);
                    if any(idx)
                        annotation=sequenceDiagramManager.Annotations(idx);
                        return;
                    end
                end
            end

            annotation=[];
            modelManager=[];
            sequenceDiagramManager=[];
        end


        function filePath=getQuasiAnnotationFilePath(obj,mdlHandle)
            mdlName=get_param(mdlHandle,'name');
            mdlFile=get_param(mdlName,'FileName');
            if isempty(mdlFile)

                filePath='';
            else
                folder=fileparts(mdlFile);
                fileName=obj.getQuasiAnnotationFileName(mdlName);
                filePath=fullfile(folder,fileName);
            end
        end


        function filePath=getQuasiAnnotationRequirementsLinkFilePath(obj,mdlHandle)
            mdlName=get_param(mdlHandle,'name');
            mdlFile=get_param(mdlName,'FileName');
            if isempty(mdlFile)
                filePath='';
            else
                folder=fileparts(mdlFile);
                fileName=obj.getQuasiAnnotationRequirementsLinkFileName(mdlName);
                filePath=fullfile(folder,fileName);
            end
        end

        function[annotation,modelName,sequenceDiagramName]=getAnnotationFromMemoryOrMatFile(obj,qaMatFile,annotationUuid)
            [annotation,modelManager,sequenceDiagramManager]=obj.findAnnotationFromUuid(annotationUuid);

            if isempty(annotation)
                [annotation,modelName,sequenceDiagramManager]=obj.getAnnotationFromMatFile(qaMatFile,annotationUuid);
            else
                modelName=get_param(modelManager.ModelHandle,'name');
            end

            sequenceDiagramName='';
            if~isempty(annotation)
                sequenceDiagramName=sequenceDiagramManager.SequenceDiagramName;
            end
        end
    end


    methods(Access=private)
        function obj=App()
            ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
            obj.SequenceDiagramOpenedListener=listener(...
            ei,'EditorOpened',...
            @(~,eventData)obj.sequenceDiagramOpened(eventData.ModelName,eventData.SequenceDiagramName));
        end


        function addImpl(obj,annotation,modelName,sequenceDiagramName)
            found=obj.findAnnotation(annotation);
            if found
                error('SequenceDiagram:QuasiAnnotation:AlreadyInSequenceDiagram',...
                'The specified annotation is already in a sequence diagram');
            end

            obj.dirtyModel(modelName);
            modelHandle=get_param(modelName,'handle');
            manager=obj.getOrCreateSequenceDiagramManager(modelHandle,sequenceDiagramName);
            manager.Annotations(end+1)=annotation;
            obj.addObjectChangedListener(annotation);
            obj.renderAnnotation(annotation,modelName,sequenceDiagramName);
        end


        function removeImpl(obj,annotation)
            [found,modelManager,sequenceDiagramManager]=obj.findAnnotation(annotation);
            if found
                idx=sequenceDiagramManager.Annotations==annotation;
                sequenceDiagramManager.Annotations(idx)=[];

                obj.removeObjectChangedListener(annotation);
                modelName=get_param(modelManager.ModelHandle,'name');
                sequenceDiagramName=sequenceDiagramManager.SequenceDiagramName;

                obj.dirtyModel(modelName);

                obj.removeAnnotationFromEditor(annotation,modelName,sequenceDiagramName);
            end
        end


        function dirtyModel(~,model)
            set_param(model,'dirty','on');
        end


        function annotations=getAllAnnotationsImpl(obj,modelHandle,sequenceDiagramName)
            annotations=sequencediagram.quasiannotation.internal.BaseAnnotation.empty();

            for mdlMgr=obj.ModelManagers
                if isempty(modelHandle)||(modelHandle==mdlMgr.ModelHandle)
                    for sdMgr=mdlMgr.SequenceDiagramManagers
                        if isempty(sequenceDiagramName)||strcmp(sequenceDiagramName,sdMgr.SequenceDiagramName)
                            annotations=[annotations,sdMgr.Annotations];%#ok<AGROW> Yes, this will likely have performance issues if many annotations are used, I don't see a clean way around it right now...
                        end
                    end
                end
            end
        end


        function addObjectChangedListener(obj,annotation)
            l=listener(annotation,...
            annotation.getAllSetObservableProperties(),'PostSet',...
            @(~,eventInfo)obj.updateAnnotation(eventInfo.AffectedObject));

            key=annotation.UUID;
            obj.AnnotationChangedListeners(key)=l;
        end


        function removeObjectChangedListener(obj,annotation)
            key=annotation.UUID;
            obj.AnnotationChangedListeners.remove(key);
        end

        function[found,modelManager,sequenceDiagramManager]=findAnnotation(obj,annotation)
            found=false;
            for modelManager=obj.ModelManagers
                for sequenceDiagramManager=modelManager.SequenceDiagramManagers
                    found=ismember(annotation,sequenceDiagramManager.Annotations);
                    if found
                        return;
                    end
                end
            end

            modelManager=[];
            sequenceDiagramManager=[];
        end


        function renderAnnotation(~,annotation,modelName,sequenceDiagramName)
            parentPanel=annotation.ParentPanel;
            annotationId=annotation.getHtmlId();
            html=annotation.generateHTML();
            ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
            ei.insertAnnotation(modelName,sequenceDiagramName,parentPanel,html,annotationId);
        end


        function removeAnnotationFromEditor(~,annotation,modelName,sequenceDiagramName)
            annotationId=annotation.getHtmlId();
            ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
            ei.removeAnnotation(modelName,sequenceDiagramName,annotationId);
        end


        function updateAnnotation(obj,annotation)
            [found,modelManager,sequenceDiagramManager]=obj.findAnnotation(annotation);
            if found
                modelName=get_param(modelManager.ModelHandle,'name');
                sequenceDiagramName=sequenceDiagramManager.SequenceDiagramName;

                obj.removeAnnotationFromEditor(annotation,modelName,sequenceDiagramName);
                obj.renderAnnotation(annotation,modelName,sequenceDiagramName);

                obj.dirtyModel(modelName);
            end
        end


        function sequenceDiagramOpened(obj,modelName,sequenceDiagramName)
            annotations=obj.getAllAnnotations(modelName,sequenceDiagramName);

            for annotation=annotations
                obj.renderAnnotation(annotation,modelName,sequenceDiagramName);
            end
        end


        function manager=getModelManager(obj,modelHandle)
            idx=[obj.ModelManagers.ModelHandle]==modelHandle;
            manager=obj.ModelManagers(idx);
        end


        function manager=getOrCreateModelManager(obj,modelHandle)
            idx=[obj.ModelManagers.ModelHandle]==modelHandle;
            needCreate=~any(idx);
            if needCreate
                manager=sequencediagram.quasiannotation.internal.ModelManager(modelHandle);
                obj.ModelManagers(end+1)=manager;
            else
                manager=obj.ModelManagers(idx);
            end
        end


        function manager=getOrCreateSequenceDiagramManager(obj,modelHandle,sequenceDiagramName)
            modelManager=obj.getOrCreateModelManager(modelHandle);
            idx=strcmp({modelManager.SequenceDiagramManagers.SequenceDiagramName},sequenceDiagramName);
            needCreate=~any(idx);
            if needCreate
                manager=sequencediagram.quasiannotation.internal.SequenceDiagramManager(sequenceDiagramName);
                modelManager.SequenceDiagramManagers(end+1)=manager;
            else
                manager=modelManager.SequenceDiagramManagers(idx);
            end
        end


        function sequenceDiagramRenamedImpl(obj,modelHandle,oldSequenceDiagramName,newSequenceDiagramName)
            oldManager=obj.getOrCreateSequenceDiagramManager(modelHandle,oldSequenceDiagramName);
            newManager=obj.getOrCreateSequenceDiagramManager(modelHandle,newSequenceDiagramName);
            newManager.Annotations=[newManager.Annotations,oldManager.Annotations];

            obj.sequenceDiagramDeletedImpl(modelHandle,oldSequenceDiagramName);
        end


        function sequenceDiagramDeletedImpl(obj,mdlHandle,sequenceDiagramName)
            modelManager=getOrCreateModelManager(obj,mdlHandle);
            idx=strcmp({modelManager.SequenceDiagramManagers.SequenceDiagramName},sequenceDiagramName);
            modelManager.SequenceDiagramManagers(idx)=[];
        end


        function blockDiagramCreated(obj,mdlName)
            subdomain=get_param(mdlName,'SimulinkSubdomain');
            if strcmp(subdomain,'Simulink')
                return;
            end

            id=obj.SimulinkCallbackId;
            mdlHandle=get_param(mdlName,'handle');
            Simulink.addBlockDiagramCallback(mdlName,...
            'PostLoad',id,...
            @()obj.getInstance().modelLoaded(mdlHandle));
            Simulink.addBlockDiagramCallback(mdlName,...
            'PostSave',id,...
            @()obj.getInstance().modelSaved(mdlHandle));

            Simulink.addBlockDiagramCallback(mdlName,...
            'PreClose',id,...
            @()obj.getInstance().modelClosed(mdlHandle));
        end


        function modelLoaded(obj,mdlHandle)
            qaFilePath=obj.getQuasiAnnotationFilePath(mdlHandle);
            if~isempty(qaFilePath)&&exist(qaFilePath,'file')
                fileContents=load(qaFilePath);
                modelManager=fileContents.ModelManager;
                modelManager.ModelHandle=mdlHandle;
                obj.ModelManagers(end+1)=modelManager;

                annotations=obj.getAllAnnotations(mdlHandle);
                arrayfun(@(a)obj.addObjectChangedListener(a),annotations);
            end

            qaReqLinkFilePath=obj.getQuasiAnnotationRequirementsLinkFilePath(mdlHandle);
            if~isempty(qaReqLinkFilePath)&&exist(qaReqLinkFilePath,'file')
                slreq.load(qaReqLinkFilePath);
            end
        end


        function modelSaved(obj,mdlHandle)            manager=obj.getModelManager(mdlHandle);
            qaFilePath=obj.getQuasiAnnotationFilePath(mdlHandle);
            if~isempty(manager)
                ModelManager=manager;
                save(qaFilePath,'ModelManager');
                obj.saveRequirementLinks(qaFilePath);
            elseif exist(qaFilePath,'file')
                delete(qaFilePath)
            end
        end


        function saveRequirementLinks(~,qaFilePath)
            linkSets=slreq.find('Type','LinkSet');
            if~isempty(linkSets)
                idx=strcmp({linkSets.Artifact},qaFilePath);
                linkSet=linkSets(idx);
                if~isempty(linkSet)
                    linkSet.save();
                end
            end
        end


        function modelClosed(obj,mdlHandle)
            annotations=obj.getAllAnnotations(mdlHandle);
            arrayfun(@(a)obj.removeObjectChangedListener(a),annotations);
            arrayfun(@(a)delete(a),annotations);

            idx=[obj.ModelManagers.ModelHandle]==mdlHandle;
            obj.ModelManagers(idx)=[];
        end


        function fileName=getQuasiAnnotationFileName(obj,mdlName)
            fileName=[mdlName,obj.MatFileSuffix];
        end


        function fileName=getQuasiAnnotationRequirementsLinkFileName(obj,mdlName)
            fileName=[mdlName,obj.ReqLinkFileSuffix];
        end


        function[annotation,modelName,sequenceDiagramManager]=getAnnotationFromMatFile(obj,qaMatFile,uuid)
            [~,qaMatFileName]=fileparts(qaMatFile);
            [~,suffixToRemove]=fileparts(obj.MatFileSuffix);
            assert(string(qaMatFileName).endsWith(suffixToRemove));
            endIdx=numel(qaMatFileName)-numel(suffixToRemove);
            modelName=qaMatFileName(1:endIdx);

            fileContents=load(qaMatFile);
            modelManager=fileContents.ModelManager;
            for sequenceDiagramManager=modelManager.SequenceDiagramManagers
                idx=strcmp([sequenceDiagramManager.Annotations.UUID],uuid);
                if any(idx)
                    annotation=sequenceDiagramManager.Annotations(idx);
                    return;
                end
            end

            annotation=[];
            sequenceDiagramManager=[];
            modelName='';
        end
    end
end


