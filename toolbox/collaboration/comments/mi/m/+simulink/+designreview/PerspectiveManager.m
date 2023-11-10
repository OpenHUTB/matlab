classdef(Hidden)PerspectiveManager<handle

    events
TogglePerspective
    end

    properties(SetAccess=private)
        modelsWithPerspective;
    end

    properties(Constant)
        iconPathOn=fullfile(fileparts(mfilename('fullpath')),'dr_inactive.png');
        iconPathOff=fullfile(fileparts(mfilename('fullpath')),'dr_active.png');
    end

    methods

        function this=PerspectiveManager()
            this.modelsWithPerspective=containers.Map('KeyType','char','ValueType','logical');
            GLUE2.addDomainTransformativeGroupCreatorCallback('Simulink','ReviewManager',...
            @this.createPerspectiveGroupCallback);
            GLUE2.addDomainTransformativeGroupCreatorCallback('Stateflow','ReviewManager',...
            @this.createPerspectiveGroupCallback);
        end


        function delete(this)%#ok<INUSD>
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Simulink','ReviewManager');
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Stateflow','ReviewManager');
        end

        function enablePerspective(this,model)
            this.modelsWithPerspective(model)=true;
        end

        function disablePerspective(this,model)
            if this.isPerspectiveEnabled(model)
                this.modelsWithPerspective.remove(model);
            end
        end

        function togglePerspective(this,editor)
            model=this.getModelName(editor);

            if this.isPerspectiveEnabled(model)
                this.disablePerspective(model);

                bd=editor.getStudio.App.blockDiagramHandle;
                studios=DAS.Studio.getAllStudios();
                for i=1:length(studios)
                    studio=studios{i};
                    if studio.App.blockDiagramHandle==bd
                        simulink.designreview.ToolStripManager.hideApp(studio);
                    end
                end
            else
                this.enablePerspective(model);
                simulink.designreview.ToolStripManager.showApp(editor.getStudio);
            end
        end

        function enabled=isPerspectiveEnabled(this,model)
            enabled=isKey(this.modelsWithPerspective,model);
        end
        function clear(this)
            keys=this.modelsWithPerspective.keys;
            for idx=1:numel(keys)
                this.modelsWithPerspective.remove(keys{idx});
            end
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Simulink','ReviewManager');
            GLUE2.removeDomainTransformativeGroupCreatorCallback('Stateflow','ReviewManager');

        end
    end

    methods(Access=private)
        function createPerspectiveGroupCallback(this,callbackInfo)
            studio=simulink.designreview.Util.getActiveStudio();
            editor=studio.App.getActiveEditor;
            if(slfeature('DesignReview_Comments')<1)
                return;
            elseif(strcmp(editor.getType,'StateflowDI:Editor')&&slfeature('DesignReview_Stateflow')<1)
                return;
            end
            info=callbackInfo.EventData;
            if info.getBlockHandle()==0
                client=info.getPerspectivesClient;
                this.displayPerspective(client);
            end
        end

        function displayPerspective(this,client)
            location=GLUE2.getPerspectivesGroupLocation('ReviewManager');
            group=client.newTransformativeGroup(DAStudio.message('designreview_comments:Command:Review'),location,false);
            modelName=this.getModelName(client.getEditor);
            if this.isPerspectiveEnabled(modelName)
                myPath=this.iconPathOff;
                tooltip=DAStudio.message('designreview_comments:Command:ReviewManagerCloseTooltip');
                bubbleStr=DAStudio.message('designreview_comments:Command:ReviewCloseBubbleText');
            else
                myPath=this.iconPathOn;
                tooltip=DAStudio.message('designreview_comments:Command:ReviewManagerOpenTooltip');
                bubbleStr=DAStudio.message('designreview_comments:Command:ReviewOpenBubbleText');
            end
            option=group.newOption('commentsoption',myPath,bubbleStr,tooltip);
            option.setSelectionCallback(@this.onClickHandler);
        end

        function onClickHandler(this,callbackInfo)
            info=callbackInfo.EventData;
            client=info.getPerspectivesClient;
            this.togglePerspective(client.getEditor);

            client.closePerspectives;
        end

        function name=getModelName(~,editor)
            studio=editor.getStudio;
            diagram=studio.App.blockDiagramHandle;
            name=bdroot(getfullname(diagram));
        end
    end
end
