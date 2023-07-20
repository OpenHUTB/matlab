classdef EditorManager<lutdesigner.service.RemotableObject

    properties(SetAccess=private)
EditorMap
    end

    methods
        function this=EditorManager()
            this.EditorMap=containers.Map;
        end

        function delete(this)
            editors=this.EditorMap.values;
            for i=1:numel(editors)
                delete(editors{i});
            end
            delete@lutdesigner.service.RemotableObject(this);
        end

        function id=getEditorRemoteIDForAccess(this,accessDesc)
            access=lutdesigner.access.Access.fromDesc(accessDesc);
            accessId=access.getId();
            if this.EditorMap.isKey(accessId)
                editor=this.EditorMap(accessId);
            else
                editor=lutdesigner.editor.Editor(access);
                this.EditorMap(accessId)=editor;
            end
            id=editor.RemoteID;
        end

        function clearEditorForAccess(this,accessDesc)
            access=lutdesigner.access.Access.fromDesc(accessDesc);
            accessId=access.getId();
            if this.EditorMap.isKey(accessId)
                delete(this.EditorMap(accessId));
                this.EditorMap.remove(accessId);
            end
        end
    end
end
