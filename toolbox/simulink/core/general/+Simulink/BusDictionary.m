






classdef BusDictionary<handle
    properties(Hidden)

        classBasedBusTypeMap=containers.Map
        registeredBusTypeMap=containers.Map


        classMDHandleMap=containers.Map




        registeredBusOriginMap=containers.Map;



        dynamicBusNameMapForRootIOPort;
    end


    methods(Access=private)
        function obj=BusDictionary()
            obj.classBasedBusTypeMap=containers.Map();
            obj.registeredBusTypeMap=containers.Map();
            obj.classMDHandleMap=containers.Map();
            obj.registeredBusOriginMap=containers.Map();
            obj.dynamicBusNameMapForRootIOPort={};
        end
    end


    methods(Static)

        function obj=getInstance()
            persistent singleObj;
            if isempty(singleObj)||~isvalid(singleObj)

                singleObj=Simulink.BusDictionary();
            end
            obj=singleObj;
        end
    end

    methods

        function obj=addClassBasedBusType(obj,name,bus)
            obj.classBasedBusTypeMap(name)=bus;
        end


        function result=classBasedBusTypeDefined(obj,name)
            result=obj.classBasedBusTypeMap.isKey(name);
        end


        function obj=deleteClassBasedBusType(obj,name)
            if obj.classBasedBusTypeDefined(name)
                remove(obj.classBasedBusTypeMap,name);
            end
        end


        function result=getClassBasedBusType(obj,name)
            result=[];
            if obj.classBasedBusTypeDefined(name)
                result=obj.classBasedBusTypeMap(name);
            end
        end


        function addClassMetaDataHandle(obj,name,mdHandle)
            obj.classMDHandleMap(name)=mdHandle;
        end


        function result=classHandleExists(obj,name)
            result=obj.classMDHandleMap.isKey(name);
        end


        function result=getclassMetaDataHandle(obj,name)
            result=[];
            if obj.classHandleExists(name)
                result=obj.classMDHandleMap(name);
            end
        end


        function obj=addRegisteredBusType(obj,name,bus)
            obj.registeredBusTypeMap(name)=bus;
        end


        function result=registeredBusTypeDefined(obj,name)
            result=obj.registeredBusTypeMap.isKey(name);
        end


        function obj=deleteRegisteredBusType(obj,name)
            if obj.registeredBusTypeDefined(name)
                remove(obj.registeredBusTypeMap,name);
            end
        end


        function result=getRegisteredBusType(obj,name)
            result=[];
            if obj.registeredBusTypeDefined(name)
                result=obj.registeredBusTypeMap(name);
            end
        end


        function addRegisteredBusOrigin(obj,name,origin)
            obj.registeredBusOriginMap(name)=origin;
        end


        function result=registeredBusOriginProvided(obj,name)
            result=obj.registeredBusOriginMap.isKey(name);
        end


        function result=getRegisteredBusOrigin(obj,name)
            result=[];
            if obj.registeredBusOriginProvided(name)
                result=obj.registeredBusOriginMap(name);
            end
        end


        function obj=deleteRegisteredBusOrigin(obj,name)
            if obj.registeredBusOriginProvided(name)
                remove(obj.registeredBusOriginMap,name);
            end
        end


        function obj=deleteRegisteredBusTypes(obj,names)
            if~isempty(names)
                for idx=1:length(names)
                    curName=names{idx};
                    obj.deleteRegisteredBusType(curName);
                    obj.deleteRegisteredBusOrigin(curName);
                end
            end
        end


        function obj=deleteAllRegisteredBusTypes(obj)
            remove(obj.registeredBusTypeMap,keys(obj.registeredBusTypeMap));
            remove(obj.registeredBusOriginMap,keys(obj.registeredBusOriginMap));
        end


        function addToDBusNameSetForRootIOPort(obj,name)
            if ischar(name)&&...
                isempty(find(strcmp(obj.dynamicBusNameMapForRootIOPort,name)))
                obj.dynamicBusNameMapForRootIOPort{end+1}=name;
            end
        end


        function result=findInDBusNameSetForRootIOPort(obj,name)
            if ischar(name)&&...
                ~isempty(find(strcmp(obj.dynamicBusNameMapForRootIOPort,name)))
                result=true;
            else
                result=false;
            end
        end





        function clearDBusNameSetForRootIOPort(obj)
            obj.dynamicBusNameMapForRootIOPort={};
        end
    end
end

