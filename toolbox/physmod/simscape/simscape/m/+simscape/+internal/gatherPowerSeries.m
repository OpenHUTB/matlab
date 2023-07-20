function gatheredLosses=gatherPowerSeries(losses)






    if~isempty(losses)

        nodeNames=losses(:,1);
        nodeLossValues=losses(:,2);
        modelIds=losses(:,3);


        uniqueModelIds=unique(modelIds,'sorted');
        nIds=length(uniqueModelIds);
        gatheredLosses=cell(nIds,2);

        for i=1:nIds


            indices=find(strcmp(uniqueModelIds{i},modelIds));








            if length(indices)>1
                nodePaths=nodeNames(indices);
                pathComponents=regexp(nodePaths,'\.','split');
                l=cellfun(@length,pathComponents);
                mindex=find(l==min(l),1);
                numCommonSubPathNames=length(pathComponents{mindex});
                for ii=1:length(indices)
                    pathComponentEqual=strcmp(pathComponents{mindex},pathComponents{ii}(1:min(l)));
                    equalIndex=find(~pathComponentEqual,1)-1;
                    numCommonSubPathNames=min([numCommonSubPathNames...
                    ,equalIndex]);
                end
                idxDot=strfind(nodePaths{mindex},'.');
                if length(idxDot)>=numCommonSubPathNames
                    idxDotLast=idxDot(numCommonSubPathNames);
                    nodePath=nodePaths{mindex}(1:idxDotLast-1);
                else
                    nodePath=nodePaths{mindex}(1:end);
                end
            else
                fullNodePath=nodeNames{indices};
                nodePath=fullNodePath;
            end


            gatheredLosses(i,1)={nodePath};
            powerSum=zeros(size(nodeLossValues{indices(1)}));
            powerSum(:,1)=nodeLossValues{indices(1)}(:,1);
            for jj=1:length(indices)
                powerSum(:,2)=powerSum(:,2)+nodeLossValues{indices(jj)}(:,2);
            end
            gatheredLosses(i,2)={powerSum};
        end
    else
        gatheredLosses={};
    end

end