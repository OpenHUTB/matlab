classdef InstanceMap<handle




    properties(Access=private)
        thisInstanceMap;
    end



    methods(Access=protected)


        function obj=InstanceMap()

            obj.thisInstanceMap=containers.Map();
        end

    end



    methods(Static)


        function theManager=getInstance()

            persistent thisInstance;
            mlock;

            if(isempty(thisInstance))

                thisInstance=Simulink.sta.InstanceMap();
            end

            theManager=thisInstance;
        end
    end



    methods


        function addUIInstance(obj,tag,aEditorH)

            obj.thisInstanceMap(tag)=aEditorH;
        end


        function aEditorH=getUIInstance(obj,tag)

            aEditorH=[];
            if obj.thisInstanceMap.isKey(tag)
                aEditorH=obj.thisInstanceMap(tag);
            end
        end


        function openTags=getOpenTags(obj)

            openTags=obj.thisInstanceMap.keys;

        end


        function count=getOpenTagCount(obj,appid)

            openTags=obj.thisInstanceMap.keys;
            count=sum(~cellfun(@isempty,strfind(openTags,appid)));
        end


        function removeTag(obj,tag)
            obj.thisInstanceMap.remove(tag);
        end


        function newTag=generateTag(obj,appid)

            count=getOpenTagCount(obj,appid);
            newTag=[appid,num2str(count)];
        end
    end

end

