classdef(Hidden)Util<handle






    methods(Static,Access=public)

        function studio=getActiveStudio()
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(studios)
                studio=studios(1);
            end
        end

        function modelName=getModelName()
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(studios)
                studio=studios(1);
                modelName=get_param(studio.App.blockDiagramHandle,'Name');
            end
        end

        function ret=isCommentsSupportedInEditor(editor)
            ret=false;
            if isempty(editor)
                return;
            end
            studio=editor.getStudio();
            model=get_param(studio.App.blockDiagramHandle,'Name');
            isReadOnlyFolder=simulink.designreview.DesignReviewApp.getInstance.isReadOnlyFolder(model);
            isTestHarness=get_param(model,'IsHarness');
            if strcmp(isTestHarness,'on')||isReadOnlyFolder
                ret=false;
            elseif(strcmp(editor.getType,'StateflowDI:Editor'))
                ret=false;
                if(slfeature('DesignReview_Stateflow')>0)
                    ret=true;
                end
            else
                ret=(editor.blockDiagramHandle==studio.App.blockDiagramHandle);
            end
        end

        function stateSelected=checkIfSingleSfElementSelected(editor)
            stateSelected=simulink.designreview.Util.isValidSFElementSelected(editor);
        end

        function validElementSelected=isValidSFElementSelected(editor)
            validElementSelected=false;
            selection=editor.getSelection;
            if(~isempty(selection)&&~selection.isEmpty()&&selection.size()==1)
                sb=selection.front;
                if(~isempty(sb))
                    root=sfroot;
                    element=root.find('id',sb.backendId);

                    if(~strcmp(element.getDisplayClass(),'Stateflow.Annotation'))



                        validElementSelected=strcmp(element.Machine.Name,simulink.designreview.Util.getModelName());
                    end
                end
            end
        end

        function modelUid=getModelUid(modelName)
            dr=simulink.designreview.DesignReviewApp.getInstance();
            modelUid=dr.getCommentsManager(modelName).getModelUid();
        end

        function blk=getSelectedBlock(editor)
            blk=simulink.designreview.UriProvider.getTargetUri(editor);
        end

        function highlightStateflowElement(uri)
            modelName=simulink.designreview.Util.getModelName();
            uriWithoutModel=extractBefore(uri,":"+modelName);
            sid=extractAfter(uriWithoutModel,"simulink:");
            sfidPart=extractAfter(uriWithoutModel,"stateflow");
            sfId=extractBefore(sfidPart,":simulink");
            if Simulink.ID.isValid(modelName+":"+sid+sfId)
                sfElement=Simulink.ID.getHandle(modelName+":"+sid+sfId);
                sfElementDigramObject=diagram.resolver.resolve(sfElement.Id,'element','stateflow');
                sfElement.Subviewer.view();
                Simulink.scrollToVisible(sfElement,'ensureFit','off','panMode','minimal');
                studio=simulink.designreview.Util.getActiveStudio();
                studio.App.hiliteAndFadeObject(sfElementDigramObject);
            else
                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('designreview_comments:Command:InvalidSFElement'),DAStudio.message('designreview_comments:Command:Error'),true);
            end
        end



        function elementId=getSFElementId(stateflowSID)
            elementId='';
            if Simulink.ID.isValid(stateflowSID)
                element=Simulink.ID.getHandle(stateflowSID);
                elementId=element.Id;
            end
        end

        function bool=isStateflowChart(hdl)
            bool=strcmp(get_param(hdl,'Type'),'block')&&strcmp(get_param(hdl,'BlockType'),'SubSystem')&&strcmp(get_param(hdl,'SFBlockType'),'Chart');
        end
    end
end
