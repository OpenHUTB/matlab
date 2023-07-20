classdef ClientMap<handle







    properties(Access=private)
thisClientMap
thisClientFileNameMap
    end



    methods(Access=protected)

        function obj=ClientMap()
            obj.thisClientMap=containers.Map();
            obj.thisClientFileNameMap=containers.Map();
        end

    end



    methods(Static)


        function thisObj=getInstance()

            persistent thisInstance;


            if(isempty(thisInstance))

                thisInstance=iofile.FromSpreadsheetBlockUI.ClientMap();
            end

            thisObj=thisInstance;
        end
    end




    methods


        function addClient(obj,appID,clientH)

            obj.thisClientMap(appID)=clientH;
        end


        function removeClient(obj,appID)
            if obj.thisClientMap.isKey(appID)
                obj.thisClientMap(appID)=[];
            end
        end


        function client=getClientMap(obj,appID)

            client=[];
            if obj.thisClientMap.isKey(appID)
                client=obj.thisClientMap(appID);
            end
        end

        function addClientFileName(obj,appID,fileName)

            obj.thisClientFileNameMap(appID)=fileName;
        end


        function removeClientFileName(obj,appID)
            if obj.thisClientFileNameMap.isKey(appID)
                obj.thisClientFileNameMap(appID)=[];
            end
        end


        function fileName=getClientFileNameMap(obj,appID)

            fileName=[];
            if obj.thisClientFileNameMap.isKey(appID)
                fileName=obj.thisClientFileNameMap(appID);
            end
        end
    end

end

