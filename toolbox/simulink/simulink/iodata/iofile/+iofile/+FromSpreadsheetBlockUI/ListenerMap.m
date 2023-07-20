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

                thisInstance=iofile.FromSpreadsheetBlockUI.ListenerMap();
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
                obj.thisListenerMap(appID)=[];
            end
        end


        function listener=getListenerMap(obj,appID)

            listener=[];
            if obj.thisListenerMap.isKey(appID)
                listener=obj.thisListenerMap(appID);
            end
        end
    end

end

