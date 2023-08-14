classdef Task_PropertyInspector<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='PropertyInspector'
    end

    methods
        function result=turnOn(obj,input,minimize)
            result=true;
            if~needsPI(input)
                return;
            end

            if nargin<3
                minimize=false;
            end

            src=simulinkcoder.internal.util.getSource(input);
            studio=src.studio;
            cmp=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');

            cps=simulinkcoder.internal.CodePerspectiveInStudio.getFromStudio(studio);
            if~isempty(cps)
                cps.data(obj.ID)=cmp.isVisible;
            end

            if~cmp.isVisible
                cmp.ShowMinimized=minimize;
                studio.showComponent(cmp);
                cmp.ShowMinimized=false;
            end
        end

        function turnOff(obj,editor)

            if~needsPI(editor)
                return;
            end

            studio=editor.getStudio;
            cmp=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            if~isempty(cmp)
                if cmp.isVisible
                    cps=simulinkcoder.internal.CodePerspectiveInStudio.getFromStudio(studio);
                    if isempty(cps)
                        studio.hideComponent(cmp);
                    else
                        data=cps.data;
                        if data.isKey(obj.ID)
                            if~data(obj.ID)
                                studio.hideComponent(cmp);
                            end
                        else
                            studio.hideComponent(cmp);
                        end
                    end
                end
            end
        end

        function bool=isAutoOn(obj,input)
            bool=true;
        end

        function refresh(obj,studio)

        end
    end
end


function out=needsPI(input)
    src=simulinkcoder.internal.util.getSource(input);
    studio=src.studio;
    h=studio.App.getActiveEditor.blockDiagramHandle;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    appName=cp.getInfo(h);
    out=strcmp(appName,'DDS');
end

