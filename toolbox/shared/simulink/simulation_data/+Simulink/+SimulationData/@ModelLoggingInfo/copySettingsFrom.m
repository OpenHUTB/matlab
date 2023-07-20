function this=copySettingsFrom(this,srcObj,srcPath,dstPath)





    validMdlRef=false;
    try
        bType=get_param(srcPath,'BlockType');
        if strcmpi(bType,'ModelReference')
            validMdlRef=true;
        end
    catch
    end



    sigs=this.getSignalsForMdlBlockOrStateflow(...
    dstPath,...
    false,...
    false);
    if~isempty(sigs)||...
        any(strcmp(this.logAsSpecifiedByModels_,dstPath))
        return
    end


    bLogAsSpec=srcObj.getLogAsSpecifiedInModel(srcPath,false);
    this=this.setLogAsSpecifiedInModel(dstPath,bLogAsSpec);


    sigs=srcObj.getSignalsForMdlBlockOrStateflow(...
    srcPath,...
    false,...
    false,...
    ~validMdlRef);


    for idx=1:length(sigs)
        if isempty(this.signals_)
            this.signals_=sigs(idx);
        else
            this.signals_(end+1)=sigs(idx);
        end


        srcSigPath=sigs(idx).blockPath_.convertToCell();
        this.signals_(end).BlockPath=...
        [dstPath;srcSigPath(2:end)];
    end

end
