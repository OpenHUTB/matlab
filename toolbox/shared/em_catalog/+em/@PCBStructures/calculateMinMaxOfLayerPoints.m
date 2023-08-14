function[minLayer,maxLayer]=calculateMinMaxOfLayerPoints(p_temp)

    minLayerPts=cell2mat(cellfun(@(x)min(x,[],2),p_temp,'UniformOutput',false));
    minLayer=min(minLayerPts,[],2);
    maxLayerPts=cell2mat(cellfun(@(x)max(x,[],2),p_temp,'UniformOutput',false));
    maxLayer=max(maxLayerPts,[],2);
end