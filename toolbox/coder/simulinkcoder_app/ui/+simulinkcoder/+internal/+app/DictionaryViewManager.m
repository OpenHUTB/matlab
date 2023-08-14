


classdef DictionaryViewManager<handle
    properties(Access=private)
ddViewMap
mdlDDViewMap
    end
    methods(Access=private)
        function obj=DictionaryViewManager()
            obj.ddViewMap=containers.Map;
            obj.mdlDDViewMap=containers.Map('KeyType','double','ValueType','any');
        end
        function h=getMap(obj,ddName)
            if isnumeric(ddName)
                h=obj.mdlDDViewMap;
            else
                h=obj.ddViewMap;
            end
        end
    end
    methods
        function view=getView(obj,ddName)
            view=[];
            m=obj.getMap(ddName);
            if isKey(m,ddName)
                view=m(ddName);
            end
        end
        function setView(obj,ddName,v)
            if isempty(v)

                obj.removeView(ddName);
            else
                m=obj.getMap(ddName);
                if m.isKey(ddName)
                    delete(m(ddName));
                end
                m(ddName)=v;%#ok
            end
        end
        function removeAllViews(obj)
            keys=obj.ddViewMap.keys;
            for i=1:length(keys)
                key=keys{i};
                obj.removeView(key);
            end
            keys=obj.mdlDDViewMap.keys;
            for i=1:length(keys)
                key=keys{i};
                obj.removeView(key);
            end
        end
        function removeView(obj,ddName)
            m=obj.getMap(ddName);
            if isKey(m,ddName)

                tmp=m(ddName);
                m.remove(ddName);
                tmp.closeDialog;
                delete(tmp);
            end
        end
        function out=getAllView(obj)
            out=obj.ddViewMap.values;
        end
        function out=getAllModelDictionayView(obj)
            out=obj.mdlDDViewMap.values;
        end
    end
    methods(Static)
        function obj=instance()
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                obj=simulinkcoder.internal.app.DictionaryViewManager();
                uniqueInstance=obj;
            else
                obj=uniqueInstance;
            end
        end
    end

end
