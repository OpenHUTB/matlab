classdef LifeCycleManager<handle

    properties(Dependent)
CurrentObject
AllObjects
    end


    properties(Hidden)
        AppdataName='managed_globe_objects'
    end


    properties(Access=private,Dependent)
Objects
    end


    methods
        function manager=LifeCycleManager(appDataName)

            if nargin>0
                manager.AppdataName=appDataName;
            end
        end


        function add(manager,objectToManage)
            managedObjects=manager.Objects;
            index=cellfun(@(x)isequal(x,objectToManage),managedObjects);
            if(isscalar(objectToManage)...
                &&(isempty(index)||all(~index))...
                &&isValidObject({objectToManage}))...
                ||isa(objectToManage,'table')
                managedObjects{end+1}=objectToManage;
                setappdata(groot,manager.AppdataName,managedObjects);
            end
        end

        function makeCurrent(manager,objectToMakeCurrent)
            managedObjects=manager.Objects;
            index=cellfun(@(x)isequal(x,objectToMakeCurrent),managedObjects);
            if isempty(index)||all(~index)

                add(manager,objectToMakeCurrent)
            elseif isscalar(objectToMakeCurrent)&&isValidObject({objectToMakeCurrent})

                managedObjects(index)=[];
                managedObjects=[managedObjects,{objectToMakeCurrent}];
                setappdata(groot,manager.AppdataName,managedObjects);
            end
        end

        function addArray(manager,arrayToManage)
            if iscell(arrayToManage)
                for k=1:length(arrayToManage)
                    add(manager,arrayToManage{k})
                end
            else
                for k=1:length(arrayToManage)
                    add(manager,arrayToManage(k))
                end
            end
        end


        function remove(manager,objectToManage)
            managedObjects=manager.Objects;
            index=cellfun(@(x)isequal(x,objectToManage),managedObjects);
            if~isempty(index)
                managedObjects(index)=[];
                setappdata(groot,manager.AppdataName,managedObjects);
            end
        end


        function removeAll(manager)
            if isappdata(groot,manager.AppdataName)
                rmappdata(groot,manager.AppdataName)
            end
        end


        function deleteAll(manager)
            objects=manager.Objects;
            for k=1:length(objects)
                try
                    obj=objects{k};
                    if isValidObject({obj})&&~isstring(obj)
                        delete(obj)
                    end
                catch
                end
            end
            if isappdata(groot,manager.AppdataName)
                rmappdata(groot,manager.AppdataName)
            end
        end


        function allObjects=get.AllObjects(manager)
            managedObjects=manager.Objects;
            if isempty(managedObjects)
                allObjects={};
            else
                tf=isValidObject(managedObjects);
                managedObjects(~tf)=[];

                name=unique(cellfun(@class,managedObjects,'UniformOutput',false));
                if isscalar(name)
                    allObjects=managedObjects{1};
                    if~isscalar(managedObjects)
                        for k=2:length(managedObjects)
                            allObjects(k)=managedObjects{k};
                        end
                    end
                else
                    allObjects=managedObjects;
                end

                if any(~tf)
                    setappdata(groot,manager.AppdataName,managedObjects);
                end
            end
        end


        function currentObject=get.CurrentObject(manager)
            managedObjects=manager.AllObjects;
            if isempty(managedObjects)
                currentObject=[];
            else
                if iscell(managedObjects)
                    currentObject=managedObjects{end};
                elseif~isa(managedObjects,'table')
                    currentObject=managedObjects(end);
                else
                    currentObject=managedObjects;
                end
            end
        end


        function managedObjects=get.Objects(manager)
            name=manager.AppdataName;
            if isappdata(groot,name)
                managedObjects=getappdata(groot,name);
            else
                managedObjects={};
            end
        end
    end
end

function index=isValidObject(cellObject)
    index=true(1,numel(cellObject));
    for k=1:numel(cellObject)
        try
            value=cellObject{k};
            index(k)=isobject(value)&&(isvalid(value)||isa(value,'table'));
        catch

        end
    end
end
