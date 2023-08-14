function outputArray=toSDI(node,~,~,varName)





























































































    modelName=node.id;
    modelLoaded=bdIsLoaded(modelName);
    source='';
    if hasSource(node)
        source=getSource(node);
    end
    parentPath='';
    outputArray=lSimscapeLogToSimulinkOutput(node,parentPath,...
    varName,modelName,modelLoaded,source,true);
end





function outputArray=lSimscapeLogToSimulinkOutput(node,parentPath,...
    varName,modelName,modelLoaded,source,firstlevel)

    nodeId=node.id;
    if(numChildren(node)>0)
        outputArray={};
        nodeChildIds=childIds(node);
        if isempty(parentPath)
            if~firstlevel
                parentPath=nodeId;
            end
        else
            parentPath=[parentPath,'.',nodeId];
        end
        for idx=1:numChildren(node)
            childNode=child(node,nodeChildIds{idx});



            if hasSource(childNode)
                source=getSource(childNode);
            end


            output=lSimscapeLogToSimulinkOutput(childNode,parentPath,...
            varName,modelName,modelLoaded,source,false);
            outputArray={outputArray{:},output{:}};%#ok<CCAT>
        end
    else
        nodeSeries=node.series;

        if(isa(nodeSeries,'simscape.logging.Series'))
            if nodeSeries.points>0
                unit=nodeSeries.unit;
                nodeValues=values(nodeSeries,unit);
                dim=nodeSeries.dimension;
                numElements=dim(1)*dim(2);




                rootSource=[varName,'.',parentPath,'.',nodeId];





                fullBlockPath=[modelName,'.',parentPath];
                fullBlockPath=strrep(fullBlockPath,'.','/');
                hierarchyReference=fullBlockPath;


                blockSource=source;

                if~isempty(source)
                    if modelLoaded
                        blockSource=pmsl_sanitizename(getfullname(source));




















                        hierarchyReference=lGetHierarchyRef(blockSource,...
                        fullBlockPath);

                    end
                end



                if(~strcmp(rootSource,''))
                    timeSource=[rootSource,'.series.time'];
                    dataSource=[rootSource,'.series.values'];
                else
                    timeSource=[nodeId,'.series.time'];
                    dataSource=[nodeId,'.series.values'];

                end

                timeValues=time(nodeSeries);
                timeDim='';



                dataValues=values(nodeSeries);
                if(dim(2)>1||dim(1)>1)
                    for j=1:dim(2)
                        for i=1:dim(1)
                            idx2=i+(j-1)*dim(1);
                            total(i,j,:)=nodeValues(idx2:numElements:end);%#ok<AGROW>
                        end
                    end

                    dataValues=total;
                    timeDim=ndims(size(dataValues));
                end


                newOutput=Simulink.sdi.internal.SimOutputExplorerOutput;
                newOutput.ModelSource=modelName;
                newOutput.SignalLabel=node.id;
                newOutput.Unit=unit;
                newOutput.RootSource=rootSource;
                newOutput.HierarchyReference=hierarchyReference;
                newOutput.BlockSource=blockSource;
                newOutput.TimeSource=timeSource;
                newOutput.DataSource=dataSource;
                newOutput.TimeValues=timeValues;
                newOutput.DataValues=dataValues;
                newOutput.TimeDim=timeDim;
                newOutput.SampleDims=dim;
                newOutput.interpolation='linear';


                outputArray={newOutput};
            else
                try
                    pm_error('physmod:common:logging2:mli:mcos:kernel:EmptyNode','simscape.logging.Node');
                catch ME
                    ME.throwAsCaller();
                end
            end
        end
    end
end

function hierarchyRef=lGetHierarchyRef(blockSource,fullBlockPath)









    bsTokens=textscan(regexprep(blockSource,'/{2,2}','_'),'%s','delimiter','/');
    bsTokenCount=numel(bsTokens{1});



    bpTokens=textscan(fullBlockPath,'%s','delimiter','/');
    bpTokenCount=numel(bpTokens{1});

    pm_assert(bpTokenCount>=bsTokenCount,'BlockPath cannot be shorter than the block source path.');




    remainStr='';
    if(bpTokenCount>bsTokenCount)
        remainStr=['/',strjoin(bpTokens{1}(bsTokenCount+1:end),'/')];
    end


    hierarchyRef=[blockSource,remainStr];
end
