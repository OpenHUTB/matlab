classdef InterpMap<lutdesigner.lutfinder.datafinder.InstanceDataMap

    methods(Access=protected)
        function dataMap=blockDataMap(this,blockHandle)
            dataspec=get_param(blockHandle,'TableSpecification');
            if strcmp(dataspec,'Explicit values')
                dataMap=this.getDataMapForExplicitTable(blockHandle);
            else
                dataMap=this.getDataMapForObject();
            end
        end

        function dataSrc=blockDataSrc(this,dataMap,blockHandle)
            import lutdesigner.data.source.UnknownDataSource
            import lutdesigner.data.proxy.CompoundExplicitMatrix
            import lutdesigner.data.proxy.CompoundLookupTable

            if strcmp(dataMap.table,"Input port")
                table=CompoundExplicitMatrix(UnknownDataSource('lutdesigner:data:parameterPortSupportLimitation'));
            else
                tableSrc=this.getParameterSource(blockHandle,dataMap.table);
                if strcmp(dataMap.table,'LookupTableObject')
                    table=lutdesigner.data.proxy.LUTOTableObject(tableSrc);
                else
                    table=this.createMatrixParameterProxy(tableSrc);
                end
            end
            axes=this.getAxesProxy(dataMap,blockHandle);
            dataSrc=CompoundLookupTable(axes,table);
        end

        function axes=getAxesProxy(this,dataMap,blockHandle)
            import lutdesigner.lutfinder.datafinder.PrelookupMap
            import lutdesigner.data.source.UnknownDataSource
            import lutdesigner.data.proxy.CompoundExplicitMatrix

            srcBlocks=this.getInterpSourceBlocks(blockHandle);
            numdims=eval(get_param(blockHandle,dataMap.numdims));
            axes=cell(1,numdims);
            for idx=1:numel(srcBlocks)
                pluSrcBlock=srcBlocks{idx};
                if strcmp(pluSrcBlock,"")
                    axes{idx}=CompoundExplicitMatrix(UnknownDataSource);
                else
                    pluInstanceMap=PrelookupMap;
                    axes{idx}=pluInstanceMap.getBlockDataProxy(pluSrcBlock);
                end
            end
        end

        function dataMap=getDataMapForExplicitTable(~,block)

            dataMap.numdims="NumberOfTableDimensions";
            if strcmp(get_param(block,'TableSource'),'Input port')
                dataMap.table="Input port";
            else
                dataMap.table="Table";
            end
            dataMap.axes=[];
            dataMap.type="explicit";
        end

        function dataMap=getDataMapForObject(~)

            dataMap.numdims="NumberOfTableDimensions";
            dataMap.table="LookupTableObject";
            dataMap.axes=[];
            dataMap.type="object";
        end

        function srcBlocks=getInterpSourceBlocks(~,interpHandle)
            assert(strcmp(get_param(interpHandle,'BlockType'),'Interpolation_n-D'));


            tableDims=eval(get_param(interpHandle,'NumberOfTableDimensions'));
            subTableDims=eval(get_param(interpHandle,'NumSelectionDims'));
            explicitDims=tableDims-subTableDims;

            isRowMajorOn=strcmp(get_param(bdroot(interpHandle),'UseRowMajorAlgorithm'),'on');
            isIndexFractionAsBus=strcmp(get_param(interpHandle,'RequireIndexFractionAsBus'),'on');
            portsParam=get_param(gcb,'Ports');
            numOfPorts=portsParam(1);
            if isRowMajorOn
                srcBlocksInsertionIndex=explicitDims+subTableDims+1;
                srcBlocksSkipIndex=-1;
            else
                srcBlocksInsertionIndex=0;
                srcBlocksSkipIndex=1;
            end
            [startIdx,endIdx,skipIdx]=getExplicitItrIdx(explicitDims,isIndexFractionAsBus,isRowMajorOn);
            [subTableStartIdx,subTableEndIdx,subTableSkipIdx]=getSubTableItrIdx(numOfPorts,subTableDims,isRowMajorOn);

            srcBlocks=cell(1,explicitDims+subTableDims);

            interpBlockConnections=get_param(interpHandle,'PortConnectivity');


            for srcIndex=startIdx:skipIdx:endIdx
                srcBlocksInsertionIndex=srcBlocksInsertionIndex+srcBlocksSkipIndex;
                if ishandle(interpBlockConnections(srcIndex).SrcBlock)
                    srcBlockHandle=get_param(interpBlockConnections(srcIndex).SrcBlock,'Handle');
                    srcBlockType=get_param(srcBlockHandle,'BlockType');

                    if strcmp(srcBlockType,'PreLookup')
                        blkPath=getfullname(srcBlockHandle);
                        srcBlocks{srcBlocksInsertionIndex}=blkPath;
                    else
                        srcBlocks{srcBlocksInsertionIndex}='';
                    end
                else
                    srcBlocks{srcBlocksInsertionIndex}='';
                end
            end

            for srcIdx=subTableStartIdx:subTableSkipIdx:subTableEndIdx
                srcBlocksInsertionIndex=srcBlocksInsertionIndex+subTableSkipIdx;
                srcBlocks{srcBlocksInsertionIndex}='';
            end
        end
    end
end

function[startIdx,endIdx,skipIdx]=getExplicitItrIdx(explicitDims,isIndexFractionAsBus,isRowMajorOn)
    if isRowMajorOn


        startIdx=(2-isIndexFractionAsBus)*explicitDims-~isIndexFractionAsBus;
        endIdx=1;
        skipIdx=-2+isIndexFractionAsBus;
    else
        startIdx=1;
        endIdx=(2-isIndexFractionAsBus)*explicitDims-~isIndexFractionAsBus;
        skipIdx=2-isIndexFractionAsBus;
    end
end

function[startIdx,endIdx,skipIdx]=getSubTableItrIdx(numOfPorts,subTableDims,isRowMajorOn)
    if isRowMajorOn


        startIdx=numOfPorts;
        endIdx=numOfPorts-subTableDims+1;
        skipIdx=-1;
    else
        startIdx=numOfPorts-subTableDims+1;
        endIdx=numOfPorts;
        skipIdx=1;
    end
end
