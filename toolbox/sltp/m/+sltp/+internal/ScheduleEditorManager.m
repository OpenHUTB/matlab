


classdef(Hidden=true)ScheduleEditorManager<handle

    methods(Static)
        function editor=getEditor(modelHandle)
            import sltp.internal.ScheduleEditorManager;

            ScheduleEditorManager.addEditorToMap(modelHandle);

            editorMap=ScheduleEditorManager.getEditorMap;
            editor=editorMap(modelHandle);
        end

        function removeEditor(modelHandle)
            import sltp.internal.ScheduleEditorManager;

            if ScheduleEditorManager.editorExists(modelHandle)
                editorMap=ScheduleEditorManager.getEditorMap();
                editor=editorMap(modelHandle);
                remove(editorMap,modelHandle);
                delete(editor);
                bd=get_param(modelHandle,'Object');
                bd.removeCallback('PreDestroy','PartitioningEditor');
            end
        end

        function hideEditor(modelHandle)
            import sltp.internal.ScheduleEditorManager;

            if ScheduleEditorManager.editorExists(modelHandle)
                editorMap=ScheduleEditorManager.getEditorMap();
                editor=editorMap(modelHandle);


                editor.Dialog.CustomWindowClosingCallback(editor.Dialog);
            end
        end

        function bool=editorExists(modelHandle)
            editorMap=sltp.internal.ScheduleEditorManager.getEditorMap;
            bool=isKey(editorMap,modelHandle);
        end
    end

    methods
        function delete(~)
            editorMap=sltp.internal.ScheduleEditorManager.getEditorMap;
            editorKeys=keys(editorMap);
            for i=1:length(editorKeys)
                sltp.internal.ScheduleEditorManager.removeEditor(editorKeys{i});
            end
        end
    end

    methods(Static,Access=private)

        function ret=getEditorMap()
            persistent hashMap;
            mlock;
            if isempty(hashMap)||~isvalid(hashMap)
                hashMap=containers.Map('KeyType','double','ValueType','any');
            end

            ret=hashMap;
        end

        function addEditorToMap(modelHandle)
            import sltp.internal.ScheduleEditorManager;

            if~ScheduleEditorManager.editorExists(modelHandle)


                editor=sltp.internal.ScheduleEditorFactory.createScheduleEditor(modelHandle);


                editorMap=ScheduleEditorManager.getEditorMap;
                editorMap(modelHandle)=editor;%#ok<NASGU>

                bd=get_param(modelHandle,'Object');
                bd.addCallback('PreDestroy','PartitioningEditor',...
                @()ScheduleEditorManager.removeEditor(modelHandle));
            end
        end
    end
end

