classdef Task_StorageClassOnSignals<simulinkcoder.internal.codeperspectivetask.BaseTask




    properties(Constant)
        ID='StorageClassOnSignals'
        menuID='showStorageClassAction';
    end

    methods
        function result=turnOn(obj,editor,~)
            result=true;





            editorModelH=editor.blockDiagramHandle;
            currentValue=get_param(editorModelH,'ShowStorageClass');
            if strcmpi(currentValue,'off')
                ts=editor.getStudio().getToolStrip();
                ts.executeActionSync(obj.menuID);
            end
        end

        function turnOff(obj,editor)


            return;

            editorModelH=editor.blockDiagramHandle;
            currentValue=get_param(editorModelH,'ShowStorageClass');
            if strcmpi(currentValue,'on')
                ts=editor.getStudio().getToolStrip();
                ts.executeActionSync(obj.menuID);
            end
        end

        function out=getStatus(obj,editor)
            studio=editor.getStudio;
            dm=studio.getDigManager;
            menu=dm.getMenuBarSchema(obj.menuID);
            out=strcmp(menu.checked,'Checked');
        end

        function bool=isAutoOn(~,~)
            bool=false;
        end
    end
end


