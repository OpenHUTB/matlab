classdef AllocationSet<handle






    properties(Dependent=true)
Name
Description
    end

    properties(SetAccess=private,Dependent=true)





Scenarios
Dirty
NeedsRefresh
    end

    properties(SetAccess=private,Dependent=true,Hidden)
Profiles
    end

    properties(SetAccess=private)
UUID
SourceModel
TargetModel
    end

    properties(Access=protected,Hidden)
Impl
MFModel
    end

    methods
        function b=isequal(this,other)

            b=isequal(this.MFModel,other.MFModel)&&isequal(this.UUID,other.UUID);
        end

        function name=get.Name(obj)
            name=obj.Impl.getName;
        end

        function set.Name(obj,newName)
            obj.Impl.setName(newName);
        end

        function name=get.Description(obj)
            name=obj.Impl.p_Description;
        end

        function set.Description(obj,desc)
            txn=obj.MFModel.beginTransaction;
            obj.Impl.p_Description=desc;
            txn.commit;
        end

        function scenarios=get.Scenarios(obj)
            scenarios=systemcomposer.allocation.internal.getWrapperForImpl(obj.Impl.getScenarios);
        end

        function profArray=get.Profiles(obj)
            profimplArray=obj.Impl.p_ProfileNamespace.Profiles;
            profArray=systemcomposer.profile.Profile.empty;
            for i=1:numel(profimplArray)
                profArray(i)=systemcomposer.profile.Profile.wrapper(profimplArray(i));
            end
        end

        function tf=get.Dirty(obj)
            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            tf=appCatalog.isAllocationSetDirty(obj.Name);
        end

        function tf=get.NeedsRefresh(obj)
            tf=obj.Impl.p_SourceModel.p_NeedsSynchronization|obj.Impl.p_TargetModel.p_NeedsSynchronization;
        end

        function save(obj,filePath)








            if nargin<2
                filePath='';
            end

            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            appCatalog.saveAllocationSet(obj.Name,filePath);
        end

        function close(obj,force)









            if(nargin<2)
                force=false;
            end
            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            appCatalog.closeAllocationSet(obj.Name,force);
            delete(obj);
        end

        function scenario=createScenario(obj,name)







            sImpl=obj.Impl.createScenario(name);
            scenario=systemcomposer.allocation.internal.getWrapperForImpl(sImpl);
        end

        function scenario=getScenario(obj,name)







            sImpl=obj.Impl.getScenario(name);
            scenario=systemcomposer.allocation.internal.getWrapperForImpl(sImpl);
        end

        function deleteScenario(obj,name)







            scenario=obj.getScenario(name);
            if~isempty(scenario)
                scenario.destroy;
            end
        end

        function synchronizeChanges(obj)








            obj.Impl.p_SourceModel.syncChanges();
            obj.Impl.p_TargetModel.syncChanges();
        end
    end

    methods(Hidden)
        function addProfile(obj,filePath)

            obj.getImpl.addProfile(filePath);
        end
        function removeProfile(obj,filePath)

            obj.getImpl.removeProfile(filePath);
        end
    end

    methods(Static)
        function allocSet=find(allocSetName)






            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            impl=appCatalog.getAllocationSet(allocSetName);
            allocSet=systemcomposer.allocation.internal.getWrapperForImpl(impl);
        end

        function closeAll()


            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            appCatalog.closeAllAllocationSets(true);
        end

        function saveAll()


            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            allocSets=appCatalog.getAllocationSets;
            for i=1:numel(allocSets)
                appCatalog.saveAllocationSet(allocSets(i).getName,'');
            end
        end
    end

    methods(Hidden)
        function obj=AllocationSet(implObj)
            assert(isa(implObj,'systemcomposer.allocation.model.AllocationSet'));
            if isempty(implObj)
                obj=systemcomposer.allocation.AllocationSet.empty;
                return
            end
            obj.Impl=implObj;
            obj.MFModel=mf.zero.getModel(implObj);
            obj.UUID=implObj.UUID;
            implObj.cachedWrapper=obj;

            try
                obj.SourceModel=systemcomposer.loadModel(implObj.p_SourceModel.p_ModelURI);
            catch
                obj.SourceModel=[];
                warning('SystemArchitecture:Allocation:CannotLoadDesignModel',...
                message('SystemArchitecture:Allocation:CannotLoadDesignModel',...
                implObj.p_SourceModel.p_ModelURI,implObj.getName).string)
            end
            try
                obj.TargetModel=systemcomposer.loadModel(implObj.p_TargetModel.p_ModelURI);
            catch
                obj.TargetModel=[];
                warning('SystemArchitecture:Allocation:CannotLoadDesignModel',...
                message('SystemArchitecture:Allocation:CannotLoadDesignModel',...
                implObj.p_TargetModel.p_ModelURI,implObj.getName).string)
            end
        end

        function impl=getImpl(obj)
            impl=obj.Impl;
        end
    end
end

