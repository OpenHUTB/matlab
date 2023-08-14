classdef EODataStore



    properties(Constant)
        EDITOR_ROOT_DATA_TAG='ROOT_DATA'
    end

    methods(Static)
        function setRootField(fieldName,fieldValue)
            import matlab.internal.editor.EODataStore

            map=EODataStore.getEditorMap(EODataStore.EDITOR_ROOT_DATA_TAG);
            map(fieldName)=fieldValue;
        end

        function value=getRootField(fieldName)
            import matlab.internal.editor.EODataStore

            map=EODataStore.getEditorMap(EODataStore.EDITOR_ROOT_DATA_TAG);
            value=[];
            if isKey(map,fieldName)
                value=map(fieldName);
            end
        end

        function clearRootField(fieldName)
            import matlab.internal.editor.EODataStore

            map=EODataStore.getEditorMap(EODataStore.EDITOR_ROOT_DATA_TAG);
            remove(map,fieldName);
        end

        function setEditorField(editorId,fieldName,fieldValue)
            import matlab.internal.editor.EODataStore
            map=EODataStore.getEditorSubMap(editorId,EODataStore.EDITOR_ROOT_DATA_TAG);
            map(fieldName)=fieldValue;
        end

        function value=getEditorField(editorId,fieldName)
            import matlab.internal.editor.EODataStore
            map=EODataStore.getEditorSubMap(editorId,EODataStore.EDITOR_ROOT_DATA_TAG);
            value=[];
            if isKey(map,fieldName)
                value=map(fieldName);
            end
        end

        function clearEditorField(editorId,fieldName)
            import matlab.internal.editor.EODataStore
            map=EODataStore.getEditorSubMap(editorId,EODataStore.EDITOR_ROOT_DATA_TAG);
            if isKey(map,fieldName)
                remove(map,fieldName);
            end
        end

        function map=getEditorSubMap(editorId,mapKey)



            import matlab.internal.editor.EODataStore;
            editorMap=EODataStore.getEditorMap(editorId);
            if~isKey(editorMap,mapKey)
                editorMap(mapKey)=containers.Map();
            end

            map=editorMap(mapKey);
        end

        function removeEditorSubMap(editorId,mapKey)


            import matlab.internal.editor.EODataStore;
            coreMap=EODataStore.getCoreMap();
            if isKey(coreMap,editorId)
                editorMap=EODataStore.getEditorMap(editorId);
                if isKey(editorMap,mapKey)
                    remove(editorMap,mapKey);
                end
            end
        end

        function removeEditorMap(editorId)

            import matlab.internal.editor.EODataStore;
            coreMap=EODataStore.getCoreMap();
            if isKey(coreMap,editorId)
                remove(coreMap,editorId);
            end
        end
    end

    methods(Static,Access=public)


        function map=getEditorMap(editorId)
            import matlab.internal.editor.EODataStore;
            coreMap=EODataStore.getCoreMap();
            if~isKey(coreMap,editorId)
                coreMap(editorId)=containers.Map();
            end

            map=coreMap(editorId);
        end

        function map=getCoreMap()



mlock
            persistent coreMap

            if isempty(coreMap)
                coreMap=containers.Map();
            end

            map=coreMap;
        end
    end
end

