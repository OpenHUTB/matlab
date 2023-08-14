




















classdef ContextGuard<handle
    properties(Hidden,Access=private)
        guardedItems=[]
    end
    methods

        function this=ContextGuard(guardedItems,guardType)
            if nargin<2

                guardType=SlCov.ContextGuardType.ModelUnchanged;
            end
            if~iscell(guardedItems)
                guardedItems={guardedItems};
            end
            for idx=1:numel(guardedItems)
                addGuard(this,guardedItems{idx},guardType);
            end
        end

        function addGuard(this,guardedItem,guardType)
            fidx=[];
            if~isempty(this.guardedItems)
                fidx=find(this.guardedItems==string(guardedItem));
            end
            if~isempty(fidx)
                SlCov.ContextGuard.guardMap('remove',this.guardedItems(fidx));
            else
                this.guardedItems=[this.guardedItems,{guardedItem}];
            end
            SlCov.ContextGuard.guardMap('init',guardedItem,guardType);
        end

        function delete(this)
            for idx=1:numel(this.guardedItems)
                SlCov.ContextGuard.guardMap('remove',this.guardedItems{idx});
            end
        end
    end

    methods(Static,Hidden)

        function res=getAllData(guardType)
            if nargin<1
                guardType=[];
            end
            res=SlCov.ContextGuard.guardMap('getAll',[],guardType);
        end

        function removeGuard(item)

            SlCov.ContextGuard.guardMap('remove',item);
        end
    end



    methods(Static,Hidden)

        function res=isUpdatedRoot(modelName,rootPath)
            res=false;
            guardData=SlCov.ContextGuard.guardMap('get',modelName,SlCov.ContextGuardType.ModelUnchanged);
            if~isempty(guardData)&&isfield(guardData,'data')&&~isempty(guardData.data)
                res=any(guardData.data==string(rootPath));
            end
        end

        function res=isModelUnchanged(modelName)
            guardData=SlCov.ContextGuard.guardMap('get',modelName,SlCov.ContextGuardType.ModelUnchanged);
            res=~isempty(guardData)&&isfield(guardData,'data')&&~isempty(guardData.data);
        end

        function addUpdatedRoot(modelName,rootPath)
            SlCov.ContextGuard.guardMap('appendData',modelName,SlCov.ContextGuardType.ModelUnchanged,rootPath);
        end
    end


    methods(Static,Hidden)

        function contextGuard=createAtomicCovQueryGuard(cvd)








            id=cvd.uniqueId;
            type=SlCov.ContextGuardType.CovResultsUnchanged;
            num_Allowed_UpdateDataIdx_Runs=1;
            contextGuard=SlCov.ContextGuard(id,type);
            SlCov.ContextGuard.guardMap('setData',id,type,num_Allowed_UpdateDataIdx_Runs);
        end

        function resetUpdateDataIdxGuard(cvd)



            id=cvd.uniqueId;
            type=SlCov.ContextGuardType.CovResultsUnchanged;
            num_Allowed_UpdateDataIdx_Runs=1;
            SlCov.ContextGuard.guardMap('setData',id,type,num_Allowed_UpdateDataIdx_Runs);
        end

        function skip=canSkipUpdateDataIdx(cvd)
            skip=false;
            id=cvd.uniqueId;
            type=SlCov.ContextGuardType.CovResultsUnchanged;
            guardData=SlCov.ContextGuard.guardMap('get',id,type);
            if~isempty(guardData)
                num_Allowed_UpdateDataIdx_Runs=guardData.data;
                if num_Allowed_UpdateDataIdx_Runs>0



                    skip=false;
                    SlCov.ContextGuard.guardMap('setData',id,type,num_Allowed_UpdateDataIdx_Runs-1);
                else



                    skip=true;
                end
            end
        end
    end

    methods(Static,Hidden,Access=private)

        function res=guardMap(cmd,guardedItem,guardType,data)
            persistent guardData;
            res=[];
            if strcmpi(cmd,'setData')


                if isempty(guardData)
                    return;
                else
                    dataIdx=find({guardData.item}==string(guardedItem)&...
                    [guardData.type]==guardType);
                    if~isempty(dataIdx)
                        guardData(dataIdx).data=data;
                    end
                end
            elseif strcmpi(cmd,'appendData')


                if isempty(guardData)
                    return;
                else
                    dataIdx=find({guardData.item}==string(guardedItem)&...
                    [guardData.type]==guardType);
                    if~isempty(dataIdx)
                        guardData(dataIdx).data{end+1}=data;
                    end
                end
            elseif strcmpi(cmd,'get')
                if~isempty(guardData)
                    res=guardData({guardData.item}==string(guardedItem));
                end
            elseif strcmpi(cmd,'init')
                addNew=true;
                if~isempty(guardData)
                    dataIdx=find({guardData.item}==string(guardedItem));
                    if~isempty(dataIdx)
                        dataIdx=find([guardData(dataIdx).type]==guardType);
                        if~isempty(dataIdx)
                            guardData(dataIdx).data={};
                            addNew=false;
                        end
                    end
                end
                if addNew
                    guardData=[guardData,struct('item',guardedItem,'type',guardType,'data',[])];
                end
            elseif strcmpi(cmd,'remove')
                if~isempty(guardData)
                    guardData({guardData.item}==string(guardedItem))=[];
                end
            elseif strcmpi(cmd,'getAll')
                if~isempty(guardType)
                    res=guardData([guardData.type]==guardType);
                else
                    res=guardData;
                end

            end
        end
    end
end
