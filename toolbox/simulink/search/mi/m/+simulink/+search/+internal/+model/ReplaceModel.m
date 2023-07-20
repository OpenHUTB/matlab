



classdef ReplaceModel<handle

    methods(Access=public)
        function obj=ReplaceModel()
            import simulink.search.internal.model.ReplaceSearchCache;
            obj.m_searchCache=ReplaceSearchCache();
            obj.m_revertGroups=containers.Map('KeyType','char','ValueType','any');

            obj.m_stop=true;


            obj.m_replaceAsyncManager=[];
            obj.m_replacePropInfos=[];
            obj.m_replaceIndex=0;
            obj.m_replacedInfoManager=[];
            obj.m_errorManager=[];
            obj.m_timeStamp='';
            obj.m_actionCallBack=[];

            obj.m_recordPerPublish=100;
        end

        function clearSearchCache(this)
            this.m_searchCache.reset();

        end

        function cacheSearchData(this,searchModel)

            searchModel.iterateOverNewResults(...
            @(searchModel,chunk,resNum)this.m_searchCache.cacheBlockInfo(searchModel,chunk,resNum)...
            );
        end

        function cacheSearchSetting(this,searchRegx,isCaseSensitive)
            this.m_searchCache.setSearchRegx(searchRegx);
            this.m_searchCache.setIsCaseSensitive(isCaseSensitive);
        end

        function cacheReplaceSetting(this,replaceRegx)
            this.m_searchCache.setReplaceRegx(replaceRegx);
        end





        function doActionAndCreateRevert(this,...
            actionCallBack,...
            isMiniView,...
            replacePropInfos,...
            timeStamp,...
            replacedInfoManager,...
errorManager...
            )
            this.m_stop=false;


            import simulink.search.internal.model.ReplaceModel;

            this.m_replacePropInfos=replacePropInfos;
            this.m_replaceIndex=0;
            this.m_timeStamp=timeStamp;
            this.m_replacedInfoManager=replacedInfoManager;
            this.m_errorManager=errorManager;
            this.m_actionCallBack=actionCallBack;

            totalRecords=numel(replacePropInfos);
            if totalRecords<=5

                this.m_recordPerPublish=totalRecords+1;
                this.replacePropertiesOnce([]);
            else

                if isempty(this.m_replaceAsyncManager)
                    this.m_replaceAsyncManager=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
                end
                this.m_recordPerPublish=ceil(totalRecords/ReplaceModel.IDEAL_PUBLISH_TIMES);
                this.m_recordPerPublish=min(this.m_recordPerPublish,ReplaceModel.MAX_RECORD_PER_PUBLISH);

                import simulink.search.internal.Util;
                this.m_replaceAsyncManager=Util.startAsyncFuncManager(...
                this.m_replaceAsyncManager,...
                @(task)(this.replacePropertiesOnce(task)),...
                @(task,err)(this.replacePropertiesOnceError(task,err))...
                );
            end
        end

        function groupRemoved=removeIfEmptyGroup(this,replaceGroup)
            groupRemoved=false;
            if isempty(replaceGroup.blocksInfo)
                groupRemoved=true;
                this.m_revertGroups(replaceGroup.timeStamp)=replaceGroup;
            end
        end

        function replaceGroup=getRevertRecords(this)
            replaceGroup=this.m_revertGroups;
        end

        function removeRecordWithErrors(this,errorManager)
            cellfun(@this.removeRecordWithErrorInfo,errorManager.errorInfos);
        end

        function removeRecordWithErrorInfo(this,errorInfo)

            if~isKey(this.m_revertGroups,errorInfo.timeStamp)
                return;
            end
            replaceGroup=this.m_revertGroups(errorInfo.timeStamp);
            replaceGroup.removeRecord(errorInfo);

            if isempty(replaceGroup.blocksInfo)
                remove(this.m_revertGroups,errorInfo.timeStamp);
            end
        end

        function doActionForSingleMatch(...
            this,...
            timeStamp,...
            blockUri,...
            propertyId,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )
            if~isKey(this.m_revertGroups,timeStamp)

                singleRecord=struct();
                singleRecord.timeStamp='ReplaceAll';
                singleRecord.blockUri=blockUri;
                singleRecord.propertyId=propertyId;
                this.doActionForRecord(...
                singleRecord,...
                actionCallBack,...
                replacedInfoManager,...
                errorManager,...
removeIfSucceed...
                );
                this.convertDeltaUpdateToState(replacedInfoManager);
                return;
            end


            singleGroup=this.m_revertGroups(timeStamp);
            singleGroup.doActionForAllRecords(...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            );
            this.convertDeltaUpdateToState(replacedInfoManager);
        end

        function doActionForRecords(...
            this,...
            records,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )
            len=numel(records);
            for i=len:-1:1
                singleRecord=records(i);
                this.doActionForRecord(...
                singleRecord,...
                actionCallBack,...
                replacedInfoManager,...
                errorManager,...
removeIfSucceed...
                );
            end
            this.convertDeltaUpdateToState(replacedInfoManager);
        end

        function doActionForAllRecords(this,actionCallBack,replacedInfoManager,errorManager,removeIfSucceed)
            revertGroups=values(this.m_revertGroups);
            len=numel(revertGroups);
            for i=len:-1:1
                singleGroup=revertGroups{i};
                singleGroup.doActionForAllRecords(...
                actionCallBack,...
                replacedInfoManager,...
                errorManager,...
removeIfSucceed...
                );
                if removeIfSucceed&&isempty(singleGroup.blocksInfo)
                    remove(this.m_revertGroups,singleGroup.timeStamp);
                end
            end
            this.convertDeltaUpdateToState(replacedInfoManager);
        end

        function doActionForRecord(...
            this,...
            singleRecord,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            )

            if~isKey(this.m_revertGroups,singleRecord.timeStamp)
                errorMessage=message(...
'simulink_ui:search:resources:CannotFindReplaceRevertRecord'...
                ).getString();
                errorManager.addErrorInfo(...
                singleRecord.timeStamp,...
                singleRecord.blockUri,...
                singleRecord.propertyId,...
errorMessage...
                );
                return;
            end
            replaceGroup=this.m_revertGroups(singleRecord.timeStamp);
            replaceGroup.doActionForRecord(...
            singleRecord,...
            actionCallBack,...
            replacedInfoManager,...
            errorManager,...
removeIfSucceed...
            );

            if removeIfSucceed&&isempty(replaceGroup.blocksInfo)
                remove(this.m_revertGroups,singleRecord.timeStamp);
            end
        end

        function forEachReplaceGroup(this,cbFunc)

            cellfun(...
            cbFunc,...
            values(this.m_revertGroups)...
            );
        end

        function clearReplaceRecords(this)
            this.m_revertGroups=containers.Map('KeyType','char','ValueType','any');
        end

        function stopAllActions(this)
            this.m_stop=true;
        end
    end

    properties(Access=protected)
        m_searchCache=[];
        m_revertGroups=[];





        m_stop=true;


        m_replaceAsyncManager=[];
        m_replacePropInfos=[];
        m_replaceIndex=[];
        m_replacedInfoManager=[];
        m_errorManager=[];
        m_timeStamp='';
        m_actionCallBack=[];
        m_recordPerPublish=100;

    end

    properties(Constant,Access=protected)

        MAX_RECORD_PER_PUBLISH=200;
        IDEAL_PUBLISH_TIMES=10;
    end

    methods(Access=protected)

        function convertDeltaUpdateToState(this,replacedInfoManager)
            len=numel(replacedInfoManager.replacedInfos);
            for idx=1:len
                replacedInfo=replacedInfoManager.replacedInfos{idx};
                statePropertyData=this.m_searchCache.getPropertyDataFromId(replacedInfo.propertyId);
                statePropertyData.highlighting.updateByDeltaReplaced(replacedInfo.propertydata);
                replacedInfo.propertydata=statePropertyData.highlighting;
            end
        end

        function replacePropertiesCompleted(this)
            this.m_replacedInfoManager.flush();
            this.m_errorManager.flush();


        end

        function replacePropertiesOnceError(this,task,err)
            this.m_replaceAsyncManager.stop();
            this.replacePropertiesCompleted();

        end

        function stopRepeating=replacePropertiesOnce(this,~)
            stopRepeating=false;

            import simulink.search.internal.Util;
            if this.m_stop
                stopRepeating=true;
                this.replacePropertiesCompleted();
                return;
            end

            totalIndex=numel(this.m_replacePropInfos);
            for i=1:this.m_recordPerPublish
                this.m_replaceIndex=this.m_replaceIndex+1;
                if this.m_replaceIndex>totalIndex
                    this.m_stop=true;
                    stopRepeating=true;
                    this.replacePropertiesCompleted();
                    return;
                end

                import simulink.search.internal.model.RevertPropertyData;
                import simulink.search.internal.model.StringHighlighting;
                replacePropInfo=this.m_replacePropInfos(this.m_replaceIndex);


                propertyData=this.m_searchCache.getPropertyDataFromId(replacePropInfo.propertyId);
                if isempty(propertyData)
                    continue;
                end


                blockUri=replacePropInfo.uri;
                blockCache=this.m_searchCache.getBlockCacheFromURI(blockUri);
                if isempty(blockCache)
                    continue;
                end


                bitArrayInfo=replacePropInfo.bitArray;
                bitArray=[];
                if~isempty(bitArrayInfo)
                    bitArray=bitArrayInfo.bitArray;



                end


                searchRegx=this.m_searchCache.getSearchRegx();
                replaceRegx=this.m_searchCache.getReplaceRegx();


                realReplaceData=RevertPropertyData('','');
                realReplaceData.setReplaceWithBitArray(propertyData,bitArray);





                [errorMessage,newPropValue]=this.m_actionCallBack(blockCache,realReplaceData);
                if~isempty(errorMessage)
                    this.m_errorManager.addErrorInfo(this.m_timeStamp,blockUri,realReplaceData.id,errorMessage);
                    continue;
                end




                propertyData.setAfterReplacedByBitArray(propertyData,bitArray);




                realReplaceData.swapOriginalAndReplace();
                realReplaceData.highlighting.originalvalue=newPropValue;


                replaceGroup=[];



                if strcmp(this.m_timeStamp,'ReplaceAll')&&isKey(this.m_revertGroups,this.m_timeStamp)
                    replaceGroup=this.m_revertGroups(this.m_timeStamp);
                end
                import simulink.search.internal.model.RevertReplaceGroup;
                if isempty(replaceGroup)
                    replaceGroup=RevertReplaceGroup(...
                    this.m_timeStamp,...
                    searchRegx,...
replaceRegx...
                    );
                    this.m_revertGroups(replaceGroup.timeStamp)=replaceGroup;
                end
                replaceGroup.addRevertRecord(blockCache,realReplaceData);


                this.m_replacedInfoManager.addReplacedInfo(propertyData.id,propertyData.highlighting);
            end
        end







    end
end
