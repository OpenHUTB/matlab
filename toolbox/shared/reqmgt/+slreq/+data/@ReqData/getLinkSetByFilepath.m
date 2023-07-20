function dataLinkSet=getLinkSetByFilepath(this,filepath)






    dataLinkSet=[];


    if ispc()
        filepath=strrep(filepath,'/',filesep);
    end
    mfLinkSet=this.findLinkSetByFilepath(filepath);
    if~isempty(mfLinkSet)
        dataLinkSet=this.wrap(mfLinkSet);
    end
end
