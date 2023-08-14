classdef SystemMap<handle




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
            v=~isempty(obj.getKeyIndex(h));
        end

        function remove(obj,h,keyIndex)
            if nargin<3
                keyIndex=obj.getKeyIndex(h);
            end
            if~isempty(keyIndex)
                obj.Keys(keyIndex)=[];
                obj.Values(keyIndex)=[];
                obj.Listeners(keyIndex)=[];
                obj.MetaClasses(keyIndex)=[];
            end
        end

        function obj=setKeyValue(obj,h,v)
            keyIndex=obj.getKeyIndex(h);
            if isempty(keyIndex)
                obj.Keys{end+1}=h;
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
            keyIndex=obj.getKeyIndex(h);
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
                if h==keys{k}
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
end
