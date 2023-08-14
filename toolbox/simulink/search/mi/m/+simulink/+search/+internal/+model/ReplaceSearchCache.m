


classdef ReplaceSearchCache<handle

    methods(Access=public)
        function obj=ReplaceSearchCache()
            obj.m_blkURIToBlkCachedInfo=containers.Map('KeyType','double','ValueType','any');
            obj.m_propIdToPropInfo=containers.Map('KeyType','int64','ValueType','any');
            obj.m_searchRegx=[];
            obj.m_replaceRegx=[];
            obj.m_isCaseSensitive=[];
        end

        function reset(this)
            this.m_blkURIToBlkCachedInfo=containers.Map('KeyType','double','ValueType','any');
            this.m_propIdToPropInfo=containers.Map('KeyType','int64','ValueType','any');
            this.m_searchRegx=[];
            this.m_replaceRegx=[];
            this.m_isCaseSensitive=[];
        end

        function setSearchRegx(this,searchRegx)
            this.m_searchRegx=searchRegx;
        end

        function setIsCaseSensitive(this,isCaseSensitive)
            this.m_isCaseSensitive=isCaseSensitive;
        end

        function setReplaceRegx(this,replaceRegx)
            this.m_replaceRegx=replaceRegx;
        end

        function searchRegx=getSearchRegx(this)
            searchRegx=this.m_searchRegx;
        end

        function isCaseSensitive=getIsCaseSensitive(this)
            isCaseSensitive=this.m_isCaseSensitive;
        end

        function replaceRegx=getReplaceRegx(this)
            replaceRegx=this.m_replaceRegx;
        end

        function propertyData=getPropertyDataFromId(this,id)
            propertyData=[];
            if~isKey(this.m_propIdToPropInfo,id)
                return;
            end
            propertyData=this.m_propIdToPropInfo(id);
        end

        function blockCache=getBlockCacheFromURI(this,uri)
            blockCache=[];
            if~isKey(this.m_blkURIToBlkCachedInfo,uri)
                return;
            end
            blockCache=this.m_blkURIToBlkCachedInfo(uri);
        end

        function cacheSearchData(this,searchModel)

            searchModel.iterateOverNewResults(@this.cacheBlockInfo);
        end

        function cacheBlockInfo(this,searchModel,chunk,resNum)


            import simulink.search.internal.model.ReplaceBlockCache;
            if~isfield(searchModel.newResultList(chunk).results(resNum),'Handle')...
                ||~isfield(searchModel.newResultList(chunk).results(resNum),'propertycollection')...
                ||isempty(searchModel.newResultList(chunk).results(resNum).propertycollection)
                return;
            end
            handle=searchModel.newResultList(chunk).results(resNum).Handle;
            newBlockCache=ReplaceBlockCache(...
            handle,...
            searchModel.newResultList(chunk).results(resNum).Name,...
            searchModel.newResultList(chunk).results(resNum).Parent,...
            searchModel.newResultList(chunk).results(resNum).Type,...
            searchModel.newResultList(chunk).results(resNum).SubType...
            );
            this.m_blkURIToBlkCachedInfo(handle)=newBlockCache;


            propertyCollection=searchModel.newResultList(chunk).results(resNum).propertycollection;

            props=values(propertyCollection.props);
            len=numel(props);
            for i=1:len
                prop=props{i};
                this.m_propIdToPropInfo(prop.id)=prop;
            end
        end
    end

    properties(Access=protected)
        m_blkURIToBlkCachedInfo=[];
        m_propIdToPropInfo=[];
        m_searchRegx=[];
        m_replaceRegx=[];
        m_isCaseSensitive=[];
    end

    methods(Access=protected)
    end
end
