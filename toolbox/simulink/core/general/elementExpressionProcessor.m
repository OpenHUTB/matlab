













classdef elementExpressionProcessor

    properties
block
memoryLayout
        expressions={};
defaultExpression
editTimeCheck
editTimeErrPrefix

        currentIndex=-1;
    end

    methods(Access=public)
        function mObj=elementExpressionProcessor(...
            blk,memLayout,entries,defaultExpr,isEditTime,errPrefix)
            mObj.block=blk;
            mObj.memoryLayout=memLayout;
            mObj.expressions=entries;
            mObj.defaultExpression=defaultExpr;
            mObj.editTimeCheck=isEditTime;
            mObj.editTimeErrPrefix=errPrefix;
        end

        function[regionDesc,entries,leafBusObjectNames]=validateExpressions(mObj)

            assert(~isempty(mObj.expressions));

            regionDesc=cell(length(mObj.expressions),1);
            leafBusObjectNames=cell(length(mObj.expressions),1);
            entries=mObj.expressions;

            for idx=1:length(mObj.expressions)
                try
                    assert(~isempty(mObj.expressions{idx}));
                    mObj.currentIndex=idx;
                    [regionDesc{idx},leafBusObjectNames{idx},semanticErrorFlag]=...
                    validateEntryAndConstructRegionDesc(mObj,entries{idx});
                    if(semanticErrorFlag)
                        assert(mObj.editTimeCheck);
                        entries{idx}=[mObj.editTimeErrPrefix,entries{idx}];
                    end
                catch me
                    throwAsCaller(me);
                end
            end
        end

    end

    methods

        function[regionDesc,leafBusObjectName]=subsref(mObj,S)

            numSubMemRegions=1;
            fieldIndices=[];
            for idx=1:length(S)
                if strcmp(S(idx).type,'.')
                    numSubMemRegions=numSubMemRegions+1;
                    fieldIndices=[fieldIndices,idx];%#ok
                end
            end

            regionDesc.numSubMemRegions=numSubMemRegions;
            isleafNode=(numSubMemRegions==1);
            leafBusObjectName=mObj.memoryLayout.BusObject;

            if isempty(leafBusObjectName)&&~isleafNode
                assert(~isempty(fieldIndices));

                throwExceptionWithBlockHandle(mObj,...
                message('Simulink:DataStores:ExpressionValidationFieldSpecifiedForNonBus',...
                S(fieldIndices(1)).subs,mObj.expressions{mObj.currentIndex},...
                mat2str(mObj.currentIndex),getBlockPath(mObj),...
                getTabNameForErrorReporting(mObj)));
            end


            regionDesc.subMemRegionInfos(1).busElementIdx=-1;
            subMemLayout=mObj.memoryLayout;
            regionDesc.subMemRegionInfos(1).subMemRegionIndexInfos=...
            getIndexingInfoFromNode(mObj,S,1,subMemLayout,isleafNode);
            regionDesc.subMemRegionInfos(1).numDims=...
            length(regionDesc.subMemRegionInfos(1).subMemRegionIndexInfos);

            subRegionCounter=2;
            for fidx=1:length(fieldIndices)
                thisFieldNodeName=S(fieldIndices(fidx)).subs;
                busElementIdx=-1;
                for cidx=1:length(subMemLayout.Children)
                    if(strcmp(thisFieldNodeName,subMemLayout.Children(cidx).Name)==1)
                        busElementIdx=cidx-1;
                        break;
                    end
                end
                if(busElementIdx==-1)
                    if isempty(leafBusObjectName)

                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationFieldSpecifiedForNonBus',...
                        thisFieldNodeName,mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),...
                        getTabNameForErrorReporting(mObj)));
                    else

                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationMissingField',...
                        thisFieldNodeName,mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),leafBusObjectName,...
                        getTabNameForErrorReporting(mObj)));
                    end
                end
                if(subRegionCounter-1==length(fieldIndices))
                    isleafNode=true;
                else
                    isleafNode=false;
                end

                leafBusObjectName=subMemLayout.Children(cidx).BusObject;
                regionDesc.subMemRegionInfos(subRegionCounter).busElementIdx=busElementIdx;
                regionDesc.subMemRegionInfos(subRegionCounter).subMemRegionIndexInfos=...
                getIndexingInfoFromNode(mObj,...
                S,fieldIndices(fidx)+1,subMemLayout.Children(cidx),isleafNode);
                regionDesc.subMemRegionInfos(subRegionCounter).numDims=...
                length(regionDesc.subMemRegionInfos(subRegionCounter).subMemRegionIndexInfos);
                subRegionCounter=subRegionCounter+1;
                subMemLayout=subMemLayout.Children(cidx);
            end
        end

    end

    methods(Access=private)

        function[regionDesc,leafBusObjectName,semanticErrorFlag]=...
            validateEntryAndConstructRegionDesc(mObj,expr)

            regionDesc=[];
            leafBusObjectName='';
            semanticErrorFlag=false;


            [expr,~]=strtok(expr,'@');
            treeRootNode=mtree(expr);


            if(iskind(treeRootNode,'ERR'))

                errCell=strings(treeRootNode);
                assert(length(errCell)==1);
                throwExceptionWithBlockHandle(mObj,...
                message('Simulink:DataStores:ExpressionValidationParseError',...
                mObj.expressions{mObj.currentIndex},...
                mat2str(mObj.currentIndex),getBlockPath(mObj),...
                errCell{1},getTabNameForErrorReporting(mObj)));
            end


            utreeRootNodes=unique(kinds(treeRootNode));
            validKinds=elementExpressionProcessor.getValidKinds();

            for idx=1:length(utreeRootNodes)
                if isempty(strmatch(utreeRootNodes{idx},validKinds,'exact'))%#ok

                    throwExceptionWithBlockHandle(mObj,...
                    message('Simulink:DataStores:ExpressionValidationUnsupportedOps',...
                    mObj.expressions{mObj.currentIndex},...
                    mat2str(mObj.currentIndex),getBlockPath(mObj),...
                    getTabNameForErrorReporting(mObj)));
                end
            end


            dsmRootNode=mtfind(treeRootNode,'Kind','ID');

            if(count(dsmRootNode)~=1)

                throwExceptionWithBlockHandle(mObj,...
                message('Simulink:DataStores:ExpressionValidationUnsupportedOps',...
                mObj.expressions{mObj.currentIndex},...
                mat2str(mObj.currentIndex),getBlockPath(mObj),...
                getTabNameForErrorReporting(mObj)));
            end

            try

                dsmName=strings(dsmRootNode);
                if strcmp(dsmName{1},mObj.memoryLayout.Name)==0

                    throwExceptionWithBlockHandle(mObj,...
                    message('Simulink:DataStores:ExpressionValidationInvalidRootName',...
                    mObj.expressions{mObj.currentIndex},...
                    mat2str(mObj.currentIndex),getBlockPath(mObj),...
                    mObj.memoryLayout.Name,getTabNameForErrorReporting(mObj)));
                end

                if strcmp(dsmName{1},expr)
                    expr=[expr,'()'];
                end

                fcnStr=['@(',dsmName{1},')',expr];

                try
                    anonFcn=str2func(fcnStr);
                catch fcn2strEx %#ok
                    mObj.editTimeCheck=false;

                    throwExceptionWithBlockHandle(mObj,...
                    message('Simulink:DataStores:ExpressionValidationUnsupportedOps',...
                    mObj.expressions{mObj.currentIndex},...
                    mat2str(mObj.currentIndex),getBlockPath(mObj),...
                    getTabNameForErrorReporting(mObj)));
                end
                [regionDesc,leafBusObjectName]=anonFcn(mObj);
            catch me
                if mObj.editTimeCheck
                    semanticErrorFlag=true;
                else
                    throwAsCaller(me);
                end
            end
        end

        function tabName=getTabNameForErrorReporting(mObj)

            ports=get_param(mObj.block,'Ports');
            assert((ports(1)==0)||(ports(2)==0));
            if(ports(1)==0)
                tabName=DAStudio.message('Simulink:blkprm_prompts:ElementSelection');
            else
                tabName=DAStudio.message('Simulink:blkprm_prompts:ElementAssignment');
            end

        end

        function indexingInfo=getIndexingInfoFromNode(mObj,S,dimsIdx,subMemLayout,isleafNode)

            indexingModes=elementExpressionProcessor.getIndexingModes();
            hasSubscript=((length(S)>=dimsIdx)&&...
            strcmp(S(dimsIdx).type,'()')&&~isempty(S(dimsIdx).subs));


            if~hasSubscript
                indexingInfo=repmat(struct('indexMode',[],'numIndices',[],'indices',[]),...
                length(subMemLayout.Dimensions),1);
                for idx=1:length(subMemLayout.Dimensions)
                    indexingInfo(idx).indexMode=indexingModes.MEM_REGION_SELECT_ALL;
                    indexingInfo(idx).numIndices=0;
                    indexingInfo(idx).indices=[];
                end
                if~isleafNode
                    if~isempty(find(subMemLayout.Dimensions>1,1))
                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationDisContiguous',...
                        mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),...
                        subMemLayout.Name,...
                        getTabNameForErrorReporting(mObj)));
                    end
                end
                return;
            end

            exprDims=S(dimsIdx).subs;
            numDims=length(exprDims);

            if(length(subMemLayout.Dimensions)~=numDims)

                throwExceptionWithBlockHandle(mObj,...
                message('Simulink:DataStores:ExpressionValidationDimsMismatch',...
                mObj.expressions{mObj.currentIndex},...
                mat2str(mObj.currentIndex),getBlockPath(mObj),...
                subMemLayout.Name,...
                mat2str(length(subMemLayout.Dimensions)),...
                getTabNameForErrorReporting(mObj)));
            end
            indexingInfo=repmat(struct('indexMode',0,'numIndices',0,'indices',[]),numDims,1);
            for idx=1:numDims
                currentDims=exprDims{idx};
                indicesForVerification=[];%#ok
                if isempty(currentDims)

                    indicesForVerification=0;
                elseif(currentDims<=-1)

                    indexingInfo(idx).indexMode=indexingModes.MEM_REGION_DYNAMIC_IDX;
                    indexingInfo(idx).numIndices=length(currentDims);
                    indexingInfo(idx).indices=currentDims;
                    indicesForVerification=currentDims*-1;

                elseif ischar(currentDims)&&strcmp(currentDims,':')

                    indexingInfo(idx).indexMode=indexingModes.MEM_REGION_SELECT_ALL;
                    indexingInfo(idx).numIndices=0;
                    indexingInfo(idx).indices=[];
                    indicesForVerification=[];
                else

                    indexingInfo(idx).indexMode=indexingModes.MEM_REGION_VECTOR;
                    indexingInfo(idx).numIndices=length(currentDims);
                    indexingInfo(idx).indices=currentDims;
                    indicesForVerification=currentDims;
                end

                maxDimsValue=subMemLayout.Dimensions(idx);
                if~isleafNode
                    if((isempty(indicesForVerification)&&(maxDimsValue~=1))||(length(indicesForVerification)>1))
                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationDisContiguous',...
                        mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),...
                        subMemLayout.Name,...
                        getTabNameForErrorReporting(mObj)));
                    end
                end

                for jdx=1:length(indicesForVerification)
                    if((indicesForVerification(jdx)<1)||...
                        (indicesForVerification(jdx)>maxDimsValue))
                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationIndexOutOfBounds',...
                        mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),...
                        subMemLayout.Name,...
                        mat2str(subMemLayout.Dimensions),...
                        getTabNameForErrorReporting(mObj)));
                    end
                end

                if~isempty(indexingInfo(idx).indices)

                    if~isequal(unique(indexingInfo(idx).indices),sort(indexingInfo(idx).indices))
                        throwExceptionWithBlockHandle(mObj,...
                        message('Simulink:DataStores:ExpressionValidationIndexRepeats',...
                        mObj.expressions{mObj.currentIndex},...
                        mat2str(mObj.currentIndex),getBlockPath(mObj),...
                        subMemLayout.Name,...
                        getTabNameForErrorReporting(mObj)));
                    end
                    if(indexingInfo(idx).indices>-1)
                        indexingInfo(idx).indices=indexingInfo(idx).indices-1;
                    end
                end
            end

        end

        function blockPath=getBlockPath(mObj)

            blockPath=[get_param(mObj.block,'Parent'),'/',get_param(mObj.block,'Name')];

        end

        function throwExceptionWithBlockHandle(mObj,msgId)




            throwAsCaller(MSLException(mObj.block,msgId));

        end

    end

    methods(Static=true,Access=private)

        function validKinds=getValidKinds()

            validKinds={'PRINT','SUBSCR','DOT','CALL','ID','INT','FIELD',...
            'LB','ROW','COLON','PARENS'};

        end

        function indexingModes=getIndexingModes()

            indexingModes.MEM_REGION_SELECT_ALL=0;
            indexingModes.MEM_REGION_STARTIDX_INCR_ENDIDX=1;
            indexingModes.MEM_REGION_VECTOR=2;
            indexingModes.MEM_REGION_VECTOR_FLATIDX=3;
            indexingModes.MEM_REGION_DYNAMIC_IDX=4;

        end
    end
end


