

classdef RevertBlockInfo<simulink.search.internal.model.PropertyCollection...
    &simulink.search.internal.model.ReplaceBlockCache
    methods(Access=public)
        function obj=RevertBlockInfo(handle,blockName,blockParentPath,type,subtype)
            import simulink.search.internal.model.RevertReplaceGroup;
            obj@simulink.search.internal.model.PropertyCollection();
            obj@simulink.search.internal.model.ReplaceBlockCache(handle,blockName,blockParentPath,type,subtype);
        end

        function addRevertRecord(this,revertPropData)
            this.props(revertPropData.id)=revertPropData;
        end

        function doActionForRecord(...
            this,...
            singleRecord,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )
            if~isKey(this.props,singleRecord.propertyId)
                return;
            end
            propertyData=this.props(singleRecord.propertyId);
            errorMessage=actionCallBack(this,propertyData);
            if~isempty(errorMessage)
                errorManager.addErrorInfo(singleRecord.timeStamp,singleRecord.blockUri,singleRecord.propertyId,errorMessage);
            else
                if removeIfSucceed
                    this.removeRecord(singleRecord);
                end
                replacedInfoManager.addReplacedInfo(propertyData.id,propertyData.highlighting);
            end

        end


        function doActionForAllRecords(...
            this,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )
            propertyDatas=values(this.props);
            len=numel(propertyDatas);
            for i=1:len
                propertyData=propertyDatas{i};
                errorMessage=actionCallBack(this,propertyData);
                if~isempty(errorMessage)
                    errorManager.addErrorInfo(0.0,this.handle,propertyData.id,errorMessage);
                else
                    if removeIfSucceed
                        remove(this.props,propertyData.id);
                    end
                    replacedInfoManager.addReplacedInfo(propertyData.id,propertyData.highlighting);
                end
            end

        end

        function removeRecord(this,singleRecord)
            if~isKey(this.props,singleRecord.propertyId)
                return;
            end
            remove(this.props,singleRecord.propertyId);
        end

        function doAction(this,actionCallBack,errorManager)
            props=values(this.props);
            cellfun(...
            @(prop)this.doActionHandleError(prop,actionCallBack,errorManager),...
props...
            );
        end
    end

    properties(Access=public)
    end

    properties(Access=protected)
    end

    methods(Access=protected)
    end
end
