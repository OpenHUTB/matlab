function[usedFcns,mergeIdxs]=getUsedFunctions(obj,op)
    usedFcns=cell(0,2);
    mergeIdxs=[];
    lastIdx=1;
    hitCache=obj.HitCache;
    for idx=1:length(hitCache)
        if obj.isDesiredOp(hitCache{idx}.Key,op)
            fcnName=hitCache{idx}.ImplementationName;
            hitSources=hitCache{idx}.HitSourceLocations;
            numHitSources=length(hitSources);
            if numHitSources>0
                mergeIdxs(end+1)=lastIdx;
                tmpList={};
                for i=1:numHitSources
                    loc=obj.getSourcelocationFromSID(hitSources{i});
                    tmpList{end+1}=loc;
                end
                tmpList=unique(tmpList);
                for idy=1:length(tmpList)
                    usedFcns{end+1,1}=fcnName;
                    usedFcns{end,2}=tmpList{idy};
                    lastIdx=lastIdx+1;
                end
                mergeIdxs(end+1)=lastIdx-1;
            end
        end
    end
end
