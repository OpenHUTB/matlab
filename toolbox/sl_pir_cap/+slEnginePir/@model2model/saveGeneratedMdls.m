function saveGeneratedMdls(this)



    if this.fInModelXform
        save_system(this.fMdl);
    else
        save_system([this.fPrefix,this.fMdl],[this.fXformDir,this.fPrefix,this.fMdl],...
        'SaveDirtyReferencedModels','on');
    end

    for m=1:length(this.fRefMdls)

        save_system([this.fPrefix,this.fRefMdls{m}],[this.fXformDir,this.fPrefix,this.fRefMdls{m}],...
        'SaveDirtyReferencedModels','on');
    end

    for m=1:length(this.fLibMdls)
        if bdIsLoaded([this.fPrefix,this.fLibMdls{m}])
            save_system([this.fPrefix,this.fLibMdls{m}],[this.fXformDir,this.fPrefix,this.fLibMdls{m}],...
            'SaveDirtyReferencedModels','on');
        end
    end
end
