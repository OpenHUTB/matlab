function isUnderflowFlag=hasUnderflows(this)






    isUnderflowFlag=cellfun(@(x)~isempty(x),this.UnderflowBins_,'UniformOutput',false);
    isUnderflowFlag=isUnderflowFlag(:);
end