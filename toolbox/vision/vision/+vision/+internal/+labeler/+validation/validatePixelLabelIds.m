function validatePixelLabelIds(labelDefs,idxPixLblId)



    if~iscell(labelDefs{:,idxPixLblId})
        error(message('vision:groundTruth:invalidPixelLabelNotCell'));
    end


    nonEmptyPixelLabelID=cellfun(@(x)~isempty(x),labelDefs{:,idxPixLblId});
    defs=labelDefs{nonEmptyPixelLabelID,idxPixLblId};


    areColumnVecs=cellfun(@(x)iscolumn(x),defs);
    areMatrices=cellfun(@(x)ismatrix(x)&&size(x,2)==3,defs);

    if~(all(areColumnVecs)||all(areMatrices))
        error(message('vision:groundTruth:labelDefsAllColumnsNotSameFormat'));
    end


    x=vertcat(defs{:});
    c=unique(x,'rows');
    if size(x,1)~=size(c,1)
        error(message('vision:groundTruth:labelDefsDuplicateIDs'));
    end
end