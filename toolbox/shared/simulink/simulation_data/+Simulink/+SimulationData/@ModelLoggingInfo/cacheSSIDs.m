function this=cacheSSIDs(this,bOpenMdl,bSkipSignals)








    for objIdx=1:length(this)


        if nargin<3||~bSkipSignals
            for idx=1:length(this(objIdx).signals_)
                this(objIdx).signals_(idx)=...
                this(objIdx).signals_(idx).cacheSSIDs(bOpenMdl);
            end
        end


        this(objIdx).logAsSpecifiedByModelsSSIDs_=...
        cell(size(this(objIdx).logAsSpecifiedByModels_));


        for idx=1:length(this(objIdx).logAsSpecifiedByModels_)


            if~strcmp(this(objIdx).logAsSpecifiedByModels_{idx},...
                this(objIdx).model_)
                try
                    this(objIdx).logAsSpecifiedByModelsSSIDs_{idx}=...
                    Simulink.ID.getSID(this(objIdx).logAsSpecifiedByModels_{idx});
                catch me %#ok


                    if bOpenMdl
                        warning(message('Simulink:Logging:DefLogSSIDCacheFailed',...
                        this(objIdx).logAsSpecifiedByModels_{idx}));
                    end
                    this(objIdx).logAsSpecifiedByModelsSSIDs_{idx}='';
                    continue;
                end
            end

        end
    end
    this(objIdx).assertSizeOfLogAsSpecifiedMatch();

end
