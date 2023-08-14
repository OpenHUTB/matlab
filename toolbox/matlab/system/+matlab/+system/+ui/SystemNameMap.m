classdef SystemNameMap<handle




    properties(Access=protected)
        Keys=cell(1,0);
        Values=cell(1,0);
        Listeners=cell(1,0);
        MetaClasses=cell(1,0);
    end

    methods
        function v=keys(obj)
            v=obj.Keys;
        end

        function v=isKey(obj,h)
            systemName=matlab.system.ui.SystemNameMap.getSystemName(h);
            v=~isempty(obj.getKeyIndex(systemName));
        end

        function remove(obj,h,keyIndex)
            systemName=h;
            if nargin<3
                keyIndex=obj.getKeyIndex(systemName);
            end
            if~isempty(keyIndex)
                obj.Keys(keyIndex)=[];
                obj.Values(keyIndex)=[];
                obj.Listeners(keyIndex)=[];
                obj.MetaClasses(keyIndex)=[];
            end
        end

        function obj=setKeyValue(obj,h,v)
            systemName=matlab.system.ui.SystemNameMap.getSystemName(h);
            keyIndex=obj.getKeyIndex(systemName);
            if isempty(keyIndex)
                obj.Keys{end+1}=systemName;
                obj.Values{end+1}=v;




                if matlab.system.isSystemObject(h)
                    obj.Listeners{end+1}=addlistener(h,'ObjectBeingDestroyed',@(src,~)matlab.system.ui.DynDialogManager.onSystemDeleted(src));
                    systemName=class(h);
                else


                    obj.Listeners{end+1}=[];
                    systemName=get(h,'System');
                end
                obj.MetaClasses{end+1}=matlab.system.internal.MetaClass(systemName);
            else
                obj.Values{keyIndex}=v;
            end
        end

        function v=getKeyValue(obj,h)
            systemName=matlab.system.ui.SystemNameMap.getSystemName(h);
            keyIndex=obj.getKeyIndex(systemName);
            if isempty(keyIndex)
                error(message('MATLAB:system:unknownSystemMapKey'));
            else
                v=obj.Values{keyIndex};
            end
        end
    end

    methods(Access=protected)
        function keyIndex=getKeyIndex(obj,h)
            keyIndex=[];
            keys=obj.Keys;
            for k=1:numel(keys)
                if strcmp(h,keys{k})
                    keyIndex=k;
                    break;
                end
            end


            if~isempty(keyIndex)
                mc=obj.MetaClasses{keyIndex};
                if isempty(mc)||~iscurrent(mc)
                    obj.remove(h,keyIndex);
                    keyIndex=[];
                end
            end
        end
    end

    methods(Static)
        function systemName=getSystemName(h)
            if matlab.system.isSystemObject(h)
                systemName=class(h);
            else
                systemName=get(h,'System');
            end
        end
    end
end