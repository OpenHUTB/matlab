classdef ListenerMap<handle







    properties(Access=private)
thisListenerMap
    end



    methods(Access=protected)

        function obj=ListenerMap()
            obj.thisListenerMap=containers.Map();
        end

    end



    methods(Static)


        function thisObj=getInstance()

            persistent thisInstance;


            if(isempty(thisInstance))

                thisInstance=Simulink.signaleditorblock.ListenerMap();
            end

            thisObj=thisInstance;
        end
    end




    methods


        function addListener(obj,appID,listener)

            obj.thisListenerMap(appID)=listener;
        end


        function removeListener(obj,appID)
            if obj.thisListenerMap.isKey(appID)
                obj.thisListenerMap.remove(appID);
            end
        end


        function listener=getListenerMap(obj,appID)

            listener=[];
            if obj.thisListenerMap.isKey(appID)
                listener=obj.thisListenerMap(appID);
            end
        end
    end

    methods(Hidden)
        function AllKeys=getAllKeys(obj)

            AllKeys=obj.thisListenerMap.keys;
        end
    end

end

