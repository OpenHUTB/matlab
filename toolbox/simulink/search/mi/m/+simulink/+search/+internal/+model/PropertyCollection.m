



classdef PropertyCollection<handle

    methods(Static,Access=public)

        function propertyCollection=createFromExistingProperty(existPropCollect,propId)
            utils.ScopedInstrumentation("propertyCollection::createFromExistingProperty");
            import simulink.search.internal.model.PropertyCollection;
            propertyCollection=PropertyCollection();


            propertyData=existPropCollect.props(propId);
            propertyCollection.props(propertyData.id)=propertyData;
        end

        function propertyCollection=createFromSearchModel(searchModel,chunk,resNum,startId)
            utils.ScopedInstrumentation("propertyCollection::createFromSearchModel");
            import simulink.search.internal.model.PropertyCollection;
            propertyCollection=PropertyCollection();


            regxFunc=searchModel.getHitCheckFunc();


            import simulink.search.internal.model.ReplaceData;
            currentResult=searchModel.newResultList(chunk).results(resNum);
            readOnlyChecker=searchModel.getReadOnlyChecker();
            blockUri=currentResult.Handle;
            fn=fieldnames(currentResult);

            fn=setdiff(fn,{'FunctionIdx','PropertyName','RealPropertyName','Type','SubType','Parent','parentsType','Handle'});

            hasModifier=searchModel.getSearchInfo().hasModifier;
            hasRealPropertyName=isfield(currentResult,'RealPropertyName');

            numOfFields=numel(fn);

            checkObjectRO=true;

            for k=1:numOfFields
                curPropName=fn{k};

                if hasModifier&&~strcmpi(curPropName,searchModel.getSearchInfo().modifier)
                    continue;
                end


                if strcmp(curPropName,'PropertyValue')
                    if~isfield(currentResult,'PropertyName')
                        continue;
                    end
                    curPropName=currentResult.PropertyName;

                end


                propertyData=ReplaceData.createFromRegx(...
                curPropName,...
                currentResult.(fn{k}),...
                searchModel.getSearchInfo().searchString,...
                regxFunc,...
startId...
                );

                if isempty(propertyData)
                    continue;
                end



                if hasRealPropertyName
                    propertyData.setRealPropertyName(currentResult.RealPropertyName);
                end
                propertyCollection.props(propertyData.id)=propertyData;

                if checkObjectRO
                    [objectReadOnly,readOnlyMessage]=readOnlyChecker.checkObject(blockUri);
                    checkObjectRO=false;
                end


                if objectReadOnly
                    propertyData.isReadOnly=objectReadOnly;
                    propertyData.readOnlyMessage=readOnlyMessage;
                else
                    [propertyData.isReadOnly,propertyData.readOnlyMessage]=readOnlyChecker.checkObjectProperty(...
                    blockUri,propertyData.propertyname...
                    );
                end
                startId=startId+1;
            end

        end

        function replaceData=getReplaceDataFromSearchModel(propName,propVal,searchString,ignoreCase,startId)
            utils.ScopedInstrumentation("propertyCollection::getReplaceDataFromSearchModel");


            import simulink.search.internal.model.ReplaceData;


            replaceData=ReplaceData.createFromRegx(...
            propName,...
            propVal,...
            searchString,...
            ignoreCase,...
startId...
            );

            if isempty(replaceData)
                return;
            end
        end
    end

    methods(Access=public)

        function propId=addExtraProperties(this,searchModel,chunk,resNum,startId)
            utils.ScopedInstrumentation("propertyCollection::addExtraProperties");
            propId=-1;




            import simulink.search.internal.model.ReplaceData;
            currentResult=searchModel.newResultList(chunk).results(resNum);
            if~isfield(currentResult,'PropertyName')...
                ||~isfield(currentResult,'PropertyValue')
                return;
            end
            curPropName=currentResult.PropertyName;


            regxFunc=searchModel.getHitCheckFunc();


            propertyData=ReplaceData.createFromRegx(...
            curPropName,...
            currentResult.PropertyValue,...
            searchModel.getSearchInfo().searchString,...
            regxFunc,...
startId...
            );

            if isempty(propertyData)
                return;
            end



            if isfield(currentResult,'RealPropertyName')
                propertyData.setRealPropertyName(currentResult.RealPropertyName);
            end


            blockUri=currentResult.Handle;
            [propertyData.isReadOnly,propertyData.readOnlyMessage]=searchModel.getReadOnlyChecker().checkObject(...
            blockUri);
            if~propertyData.isReadOnly
                [propertyData.isReadOnly,propertyData.readOnlyMessage]=searchModel.getReadOnlyChecker().checkObjectProperty(...
                blockUri,propertyData.propertyname...
                );
            end

            this.props(propertyData.id)=propertyData;
            propId=propertyData.id;
        end
    end

    methods(Access=public)
        function obj=PropertyCollection()
            obj.props=containers.Map('KeyType','int64','ValueType','any');
            obj.isDeltaUpdate=false;
        end
    end

    properties(Access=public)

        props;



        isDeltaUpdate;
    end
end
