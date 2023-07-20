


classdef IPCoreList<handle


    properties

    end

    properties(Access=protected)
        hIPDriver=[];

        IPCoreMap=[];


    end


    methods

        function obj=IPCoreList(hIPD)


            obj.hIPDriver=hIPD;
            obj.IPCoreMap=containers.Map;
        end

    end

    methods
        function hIPCore=addIPCoreForDUT(obj,dutName)
            hIPCore=hdlturnkey.ip.IPCore(obj.hIPDriver,dutName);
            obj.addIPCore(hIPCore);
        end

        function hIPCore=getIPCore(obj,dutName)

            if length(obj.IPCoreMap)>1
                error('Multiple IP cores exists in map. Only expected one IP core to be present in map.');
            end

            hIPCore=obj.IPCoreMap.values;
            hIPCore=hIPCore{1};







        end

        function dutNameList=getDUTNameList(obj)
            dutNameList=obj.IPCoreMap.keys;
        end
    end

    methods(Access=protected)
        function addIPCore(obj,hIPCore)
            dutName=hIPCore.DUTName;

            if~obj.IPCoreMap.isKey(dutName)
                obj.IPCoreMap(dutName)=hIPCore;

            else
                error('Can not add IP core for DUT "%s" because an IP Core for the same DUT already exists.',dutName);

            end
        end
    end
end
