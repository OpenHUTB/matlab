




classdef SearchModel<handle
    methods(Static,Access=public)
        function[searchModel,instanceManager]=createSearchModel(uri)
            searchModel=[];
            import simulink.search.internal.SearchInstanceManager;
            instanceManager=SearchInstanceManager.createSearchInstanceManager(uri);
            if isempty(instanceManager)
                return;
            end
            searchModel=instanceManager.getSearchModel();
            if isempty(searchModel)
                searchModel=instanceManager.createSearchModel();
            end
        end

        function searchModel=getSearchModel(uri)
            searchModel=[];
            import simulink.search.internal.SearchInstanceManager;
            instanceManager=SearchInstanceManager.getSearchInstanceManager(uri);
            if isempty(instanceManager)
                return;
            end
            searchModel=instanceManager.getSearchModel();
        end

        function searchModel=clearResults(uri)
            searchModel=[];
            import simulink.search.internal.SearchInstanceManager;
            instanceManager=SearchInstanceManager.getSearchInstanceManager(uri);
            if isempty(instanceManager)
                return;
            end
            searchModel=instanceManager.clearResults();
        end

        function debugInfo=getDebugInfo()
            persistent sDebugInfo
            if isempty(sDebugInfo)
                import simulink.search.internal.finderModel.DebugInfo;
                sDebugInfo=DebugInfo();
            end
            debugInfo=sDebugInfo;
        end
    end

    methods(Access=public)
        function obj=SearchModel()

            import simulink.search.internal.finderModel.SearchSystems;


            obj.searchSystems=SearchSystems();
            obj.newResultList=[];

            obj.m_replaceRegx=[];
            obj.m_searchInfo=[];
            obj.m_isCaseSensitive=false;
            obj.m_blkUriToPropCollection=containers.Map('KeyType','double','ValueType','any');

            import simulink.search.internal.model.PropertyCollection;
            obj.m_propertyCollections={};

            obj.m_currentId=0;

            obj.m_isSearchActive=false;

            import simulink.search.internal.model.ReadOnlyCheckService;
            import simulink.search.internal.model.PropertyReadOnlyChecker;
            import simulink.search.internal.model.LibraryLinkReadOnlyChecker;
            import simulink.search.internal.model.LockedLibraryChecker;
            import simulink.search.internal.model.InsideReadOnlySubsystemChecker;
            import simulink.search.internal.model.AnnotationsReadOnlyChecker;

            obj.m_readOnlyChecker=ReadOnlyCheckService();
            obj.m_readOnlyChecker.registerChecker(PropertyReadOnlyChecker());
            obj.m_readOnlyChecker.registerChecker(LibraryLinkReadOnlyChecker());
            obj.m_readOnlyChecker.registerChecker(LockedLibraryChecker());
            obj.m_readOnlyChecker.registerChecker(InsideReadOnlySubsystemChecker());
            obj.m_readOnlyChecker.registerChecker(AnnotationsReadOnlyChecker());


            obj.searchDepth='top';

            obj.m_advancedParameter=[];
            obj.m_advancedParameterHasInit=false;
        end

        function reset(this)

            import simulink.search.internal.finderModel.SearchSystems;
            this.searchSystems=SearchSystems();
            this.newResultList=[];

            this.m_replaceRegx=[];
            this.m_searchInfo=[];
            this.m_isCaseSensitive=false;
            this.m_blkUriToPropCollection=containers.Map('KeyType','double','ValueType','any');

            import simulink.search.internal.model.PropertyCollection;
            this.m_propertyCollections={};

            this.m_currentId=0;

            this.m_isSearchActive=false;

            import simulink.search.internal.model.ReadOnlyCheckService;
            import simulink.search.internal.model.PropertyReadOnlyChecker;
            import simulink.search.internal.model.LibraryLinkReadOnlyChecker;
            import simulink.search.internal.model.InsideReadOnlySubsystemChecker;
            import simulink.search.internal.model.AnnotationsReadOnlyChecker;

            this.m_readOnlyChecker=ReadOnlyCheckService();
            this.m_readOnlyChecker.registerChecker(PropertyReadOnlyChecker());
            this.m_readOnlyChecker.registerChecker(LibraryLinkReadOnlyChecker());
            this.m_readOnlyChecker.registerChecker(InsideReadOnlySubsystemChecker());
            this.m_readOnlyChecker.registerChecker(AnnotationsReadOnlyChecker());
        end

        function isActive=isSearchActive(this)
            isActive=this.m_isSearchActive;
        end

        function setIsSearchActive(this,isActive)
            this.m_isSearchActive=isActive;
        end

        function clearSearch(this)
            if(~isempty(this.searchSystems.results))
                this.searchSystems.results=[];
                this.searchSystems.handleToResultIdx=containers.Map('KeyType','double','ValueType','double');
                this.searchSystems.parentToHierarchyType=containers.Map('KeyType','char','ValueType','char');
            end
            this.newResultList=[];

            this.m_replaceRegx=[];
            this.m_searchInfo=[];
            this.m_isCaseSensitive=false;
            this.m_blkUriToPropCollection=containers.Map('KeyType','double','ValueType','any');

            import simulink.search.internal.model.PropertyCollection;
            this.m_propertyCollections={};
            this.m_isSearchActive=false;
        end

        function studioTag=getStudioTag(this)
            studioTag=this.searchSystems.studioTag;
        end

        function documentListener=getDocumentListener(this)
            documentListener=this.s_documentListener;
        end

        function generateSearchRegx(this)
            utils.ScopedInstrumentation("searchModel::generateSearchRegx");
            if~isempty(this.m_searchInfo)
                return;
            end
            len=numel(this.searchSystems.searchModelRef.findArgument);


            foundSearchInfo=false;
            foundCaseSensitive=false;
            this.m_isCaseSensitive=false;
            for i=1:len-1
                if~ischar(this.searchSystems.searchModelRef.findArgument{i})
                    continue;
                end
                if~foundSearchInfo...
                    &&(strcmp(this.searchSystems.searchModelRef.findArgument{i},'SimpleAndParams')||...
                    strcmp(this.searchSystems.searchModelRef.findArgument{i},'Simple'))
                    this.m_searchInfo=...
                    this.searchSystems.searchModelRef.findArgument{i+1};
                    foundSearchInfo=true;
                    if foundCaseSensitive
                        break;
                    end
                end
                if~foundCaseSensitive...
                    &&strcmp(this.searchSystems.searchModelRef.findArgument{i},'CaseSensitive')
                    this.m_isCaseSensitive=...
                    strcmp(this.searchSystems.searchModelRef.findArgument{i+1},'on');
                    foundCaseSensitive=true;
                    if foundSearchInfo
                        break;
                    end
                end
            end
        end

        function searchRegx=getSearchRegx(this)
            searchRegx=[];
            if isempty(this.m_searchInfo)

                return;
            end
            searchRegx=this.m_searchInfo.searchString;
        end

        function replaceRegx=getReplaceRegx(this)
            replaceRegx=this.m_replaceRegx;
        end

        function readOnlyChecker=getReadOnlyChecker(this)
            readOnlyChecker=this.m_readOnlyChecker;
        end

        function iterateOverNewResults(this,cbFunc)
            if isempty(this.newResultList)
                return;
            end
            resChunkLength=numel(this.newResultList);
            for chunk=1:resChunkLength
                resLength=numel(this.newResultList(chunk).results);
                for resNum=1:resLength
                    cbFunc(this,chunk,resNum);
                end
            end
        end

        function addPropertyInfo(this)
            utils.ScopedInstrumentation("searchModel::addPropertyInfo");
            if isempty(this.newResultList)
                return;
            end
            resChunkLength=numel(this.newResultList);

            import simulink.search.internal.model.PropertyCollection;
            startId=this.m_currentId;
            if isempty(this.m_searchInfo)
                this.generateSearchRegx();
                if isempty(this.m_searchInfo)

                    return;
                end
            end

            for chunk=1:resChunkLength
                simulink.FindSystemTask.Testing.startPerfRecordingFor("searchModel::processingNewResultList");
                resLength=numel(this.newResultList(chunk).results);
                for resNum=1:resLength


                    blockUri=this.newResultList(chunk).results(resNum).Handle;
                    if~isKey(this.m_blkUriToPropCollection,blockUri)
                        propertyCollection=PropertyCollection.createFromSearchModel(...
                        this,chunk,resNum,startId...
                        );
                        this.m_propertyCollections{end+1}=propertyCollection;
                        this.newResultList(chunk).results(resNum).propertycollection=propertyCollection;
                        this.m_blkUriToPropCollection(blockUri)=propertyCollection;
                        startId=startId+propertyCollection.props.Count;
                    else


                        propertyCollection=this.m_blkUriToPropCollection(blockUri);
                        propId=propertyCollection.addExtraProperties(...
                        this,chunk,resNum,startId...
                        );
                        if propId>=0
                            newPropertyCollection=PropertyCollection.createFromExistingProperty(propertyCollection,propId);
                            newPropertyCollection.isDeltaUpdate=true;
                            this.newResultList(chunk).results(resNum).propertycollection=newPropertyCollection;
                            startId=startId+1;
                        end
                    end
                end
                simulink.FindSystemTask.Testing.stopPerfRecordingFor("searchModel::processingNewResultList");
            end
            this.m_currentId=startId;
        end

        function addPropertyInfo2(this)
            utils.ScopedInstrumentation("searchModel::addPropertyInfo");
            if isempty(this.newResultList)||slfeature('FindSystemSupportForReturningPropMatches')==0
                return;
            end
            resChunkLength=numel(this.newResultList);

            startId=this.m_currentId;
            simulink.FindSystemTask.Testing.startPerfRecordingFor("searchModel::processingNewResultList");
            if isempty(this.m_searchInfo)
                this.generateSearchRegx();
                if isempty(this.m_searchInfo)

                    return;
                end
            end
            import simulink.search.internal.model.PropertyCollection;
            import simulink.search.internal.model.ReplaceData;
            for chunk=1:resChunkLength
                resLength=numel(this.newResultList(chunk).results);
                for resNum=1:resLength

                    parentsType='';
                    if isfield(this.newResultList(chunk).results(resNum),'Parent')
                        parentsType=this.searchSystems.getParentsType(this.newResultList(chunk).results(resNum).Parent);
                    end
                    this.newResultList(chunk).results(resNum).parentsType=parentsType;




                    blockUri=this.newResultList(chunk).results(resNum).Handle;


                    propcolFound=false;
                    if isfield(this.newResultList(chunk).results(resNum),'propertycollection')&&...
                        ~isempty(this.newResultList(chunk).results(resNum).propertycollection)
                        propcolFound=true;
                    end



                    if~isKey(this.m_blkUriToPropCollection,blockUri)
                        if propcolFound
                            curPropCollections=this.newResultList(chunk).results(resNum).propertycollection;
                            numOfPropCols=length(curPropCollections);
                            propertyCollection=PropertyCollection();
                            nameMatched=false;
                            descMatched=false;

                            checkObjectRO=true;

                            for i=1:numOfPropCols
                                curPropCol=this.newResultList(chunk).results(resNum).propertycollection(i);

                                if strcmp(curPropCol.propertyname,'Name')
                                    nameMatched=true;
                                elseif strcmp(curPropCol.propertyname,'Description')
                                    descMatched=true;
                                end

                                replaceData=ReplaceData(startId,...
                                curPropCol.propertyname,...
                                curPropCol.originalvalue,...
                                curPropCol.splitNonMatch,...
                                curPropCol.hitsubstrings);

                                if isfield(this.newResultList(chunk).results(resNum),'RealPropertyName')
                                    replaceData.setRealPropertyName(this.newResultList(chunk).results(resNum).RealPropertyName);
                                end

                                if checkObjectRO
                                    [objectReadOnly,readOnlyMessage]=this.m_readOnlyChecker.checkObject(blockUri);
                                    checkObjectRO=false;
                                end

                                if objectReadOnly
                                    replaceData.isReadOnly=objectReadOnly;
                                    replaceData.readOnlyMessage=readOnlyMessage;
                                else
                                    [replaceData.isReadOnly,replaceData.readOnlyMessage]=this.m_readOnlyChecker.checkObjectProperty(...
                                    blockUri,replaceData.propertyname...
                                    );
                                end

                                propertyCollection.props(startId)=replaceData;
                                propertyCollection.isDeltaUpdate=false;
                                startId=startId+1;
                            end



                            fn=fieldnames(this.newResultList(chunk).results(resNum));

                            fn=setdiff(fn,{'FunctionIdx','Handle','Type','SubType','Name','Description','Parent','parentsType','PropertyName','PropertyValue','RealPropertyName','propertycollection'});

                            if~nameMatched
                                fn{end+1}='Name';
                            end

                            if~descMatched
                                fn{end+1}='Description';
                            end

                            if~isempty(fn)
                                numOfFields=numel(fn);
                                hasModifier=this.getSearchInfo().hasModifier;

                                for k=1:numOfFields
                                    if hasModifier&&~strcmpi(fn{k},this.getSearchInfo().modifier)
                                        continue;
                                    end

                                    if isempty(this.newResultList(chunk).results(resNum).(fn{k}))
                                        continue;
                                    end

                                    replaceData=PropertyCollection.getReplaceDataFromSearchModel(...
                                    fn{k},this.newResultList(chunk).results(resNum).(fn{k}),this.getSearchInfo().searchString,this.getHitCheckFunc(),startId);

                                    if~isempty(replaceData)
                                        if objectReadOnly
                                            replaceData.isReadOnly=objectReadOnly;
                                            replaceData.readOnlyMessage=readOnlyMessage;
                                        else
                                            [replaceData.isReadOnly,replaceData.readOnlyMessage]=this.m_readOnlyChecker.checkObjectProperty(...
                                            blockUri,replaceData.propertyname);
                                        end

                                        propertyCollection.props(startId)=replaceData;
                                        startId=startId+1;
                                    end
                                end
                            end

                        else
                            propertyCollection=PropertyCollection.createFromSearchModel(...
                            this,chunk,resNum,startId);
                            if~isempty(propertyCollection)&&propertyCollection.props.Count>0
                                startId=startId+propertyCollection.props.Count;
                            end
                        end
                        this.m_propertyCollections{end+1}=propertyCollection;
                        this.newResultList(chunk).results(resNum).propertycollection=propertyCollection;
                        this.m_blkUriToPropCollection(blockUri)=propertyCollection;
                    else


                        propertyCollection=this.m_blkUriToPropCollection(blockUri);
                        if propcolFound
                            numOfPropCols=length(this.newResultList(chunk).results(resNum).propertycollection);


                            checkObjectRO=true;

                            for i=1:numOfPropCols
                                curPropCol=this.newResultList(chunk).results(resNum).propertycollection(i);
                                replaceData=ReplaceData(startId,...
                                curPropCol.propertyname,...
                                curPropCol.originalvalue,...
                                curPropCol.splitNonMatch,...
                                curPropCol.hitsubstrings);

                                if isfield(this.newResultList(chunk).results(resNum),'RealPropertyName')
                                    replaceData.setRealPropertyName(this.newResultList(chunk).results(resNum).RealPropertyName);
                                end


                                if checkObjectRO
                                    [objectReadOnly,readOnlyMessage]=this.m_readOnlyChecker.checkObject(blockUri);
                                    checkObjectRO=false;
                                end

                                if objectReadOnly
                                    replaceData.isReadOnly=objectReadOnly;
                                    replaceData.readOnlyMessage=readOnlyMessage;
                                else
                                    [replaceData.isReadOnly,replaceData.readOnlyMessage]=this.m_readOnlyChecker.checkObjectProperty(...
                                    blockUri,curPropCol.propertyname);
                                end

                                propertyCollection.props(startId)=replaceData;

                                newpropertyCollection=PropertyCollection();
                                newpropertyCollection.props(startId)=replaceData;
                                newpropertyCollection.isDeltaUpdate=true;
                                this.newResultList(chunk).results(resNum).propertycollection=newpropertyCollection;
                                startId=startId+1;
                            end

                        else
                            propId=propertyCollection.addExtraProperties(...
                            this,chunk,resNum,startId...
                            );
                            if propId>=0
                                newPropertyCollection=PropertyCollection.createFromExistingProperty(propertyCollection,propId);
                                newPropertyCollection.isDeltaUpdate=true;
                                this.newResultList(chunk).results(resNum).propertycollection=newPropertyCollection;
                                startId=startId+1;
                            end
                        end
                    end
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("searchModel::processingNewResultList");
            this.m_currentId=startId;
        end








































        function updateReplaceRegx(this,replaceRegx)
            utils.ScopedInstrumentation("searchModel::updateReplaceRegx");
            this.m_replaceRegx=replaceRegx;
            len=numel(this.m_propertyCollections);
            for i=1:len
                propertyCollection=this.m_propertyCollections{i};
                cellfun(...
                @(prop)prop.updateReplaceRegx(this.m_searchInfo.searchString,replaceRegx),...
                values(propertyCollection.props)...
                );
            end
        end

        function propInfo=getPropertyInfo(this)
            propInfo=this.m_propertyCollections;
        end

        function searchInfo=getSearchInfo(this)
            searchInfo=this.m_searchInfo;
        end

        function isCaseSensitive=getIsCaseSensitive(this)
            isCaseSensitive=this.m_isCaseSensitive;
        end

        function caseFuncString=getHitCheckFunc(this)
            if this.m_isCaseSensitive
                caseFuncString='matchcase';
            else
                caseFuncString='ignorecase';
            end
        end

        function out=advancedParameter(this,data)
            import simulink.search.internal.finderModel.SearchSystems;
            if nargin==2
                this.m_advancedParameter=data;
                SearchSystems.globalAdvancedParameter(data);
                out=[];
                return;
            end
            if(~this.m_advancedParameterHasInit)
                this.m_advancedParameterHasInit=true;
                this.m_advancedParameter=SearchSystems.globalAdvancedParameter();
            end
            out=this.m_advancedParameter;
        end
    end

    properties(Access=public)


        searchSystems=[];
        newResultList=[];
        searchDepth='';
    end

    properties(Access=protected)

        m_replaceRegx=[];
        m_propertyCollections={};
        m_searchInfo=[];
        m_isCaseSensitive=false;
        m_blkUriToPropCollection=[];
        m_debugInfo=[];

        m_currentId=0;

        m_readOnlyChecker=[];

        m_advancedParameter=[];
        m_advancedParameterHasInit=false;

        m_isSearchActive=false;


        s_documentListener=simulink.search.internal.finderModel.DocumentListener();
    end

    methods(Access=protected)
    end
end
