function mfLinkSet=findLinkSetByFilepath(this,slmxPath)






    mfLinkSet=[];

    if isempty(this.repository)
        return;
    end

    mfLinkSets=this.repository.linkSets.toArray();
    for i=1:length(mfLinkSets)
        mfCurrent=mfLinkSets(i);
        if strcmp(mfCurrent.filepath,slmxPath)
            mfLinkSet=mfCurrent;
            break;
        end
    end
end
