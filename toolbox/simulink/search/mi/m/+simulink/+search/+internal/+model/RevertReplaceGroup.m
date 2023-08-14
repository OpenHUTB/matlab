

classdef RevertReplaceGroup<handle

    methods(Access=public)
        function obj=RevertReplaceGroup(timeStamp,searchRegx,replaceRegx)
            obj.timeStamp=timeStamp;
            obj.timeStampStr=obj.timeStamp;
            obj.searchRegx=searchRegx;
            obj.replaceRegx=replaceRegx;
            obj.blocksInfo=containers.Map('KeyType','double','ValueType','any');
        end

        function doActionForRecord(...
            this,...
            singleRecord,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )

            if~isKey(this.blocksInfo,singleRecord.blockUri)
                return;
            end
            blkInfo=this.blocksInfo(singleRecord.blockUri);
            blkInfo.doActionForRecord(...
            singleRecord,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            );

            if removeIfSucceed&&isempty(blkInfo.props)
                remove(this.blocksInfo,singleRecord.blockUri);
            end
        end

        function doActionForAllRecords(...
            this,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )
            blkInfos=values(this.blocksInfo);
            len=numel(blkInfos);
            for i=1:len
                blkInfo=blkInfos{i};
                blkInfo.doActionForAllRecords(...
                actionCallBack,...
                replacedInfoManager,...
                errorManager,...
removeIfSucceed...
                );
            end
            if removeIfSucceed
                this.blocksInfo=containers.Map('KeyType','double','ValueType','any');
            end
        end

        function removeRecord(this,singleRecord)

            if~isKey(this.blocksInfo,singleRecord.blockUri)
                return;
            end
            blkInfo=this.blocksInfo(singleRecord.blockUri);
            blkInfo.removeRecord(singleRecord);

            if isempty(blkInfo.props)
                remove(this.blocksInfo,singleRecord.blockUri);
            end
        end













        function addRevertRecord(this,blockCache,revertPropData)
            import simulink.search.internal.model.RevertBlockInfo;
            if~isKey(this.blocksInfo,blockCache.handle)
                blockInfo=RevertBlockInfo(blockCache.handle,blockCache.name,blockCache.parent,blockCache.type,blockCache.subtype);
                this.blocksInfo(blockInfo.handle)=blockInfo;
            else
                blockInfo=this.blocksInfo(blockCache.handle);
            end
            blockInfo.addRevertRecord(revertPropData);
        end
    end

    properties(Access=public)


        timeStamp=[];
        timeStampStr=[];
        searchRegx=[];
        replaceRegx=[];
        blocksInfo=[];
    end
end
