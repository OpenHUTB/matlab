function this=refreshFromSSIDcache(this,bOpenMdl,bTopMdlOnly)








    if nargin<3
        bTopMdlOnly=false;
    end

    for objIdx=1:length(this)


        for idx=1:length(this(objIdx).signals_)


            if bTopMdlOnly&&~this(objIdx).signalIsInTopMdl(idx)
                continue;
            end

            try
                this(objIdx).signals_(idx)=...
                this(objIdx).signals_(idx).refreshFromSSIDcache(bOpenMdl);
            catch me
                if bOpenMdl
                    warning(me.identifier,me.message);
                end
            end
        end


        if~isempty(this(objIdx).logAsSpecifiedByModelsSSIDs_)


            this(objIdx).assertSizeOfLogAsSpecifiedMatch();


            for idx=1:length(this(objIdx).logAsSpecifiedByModels_)
                if~isempty(this(objIdx).logAsSpecifiedByModelsSSIDs_{idx})


                    try
                        blk=...
                        Simulink.ID.getHandle(this(objIdx).logAsSpecifiedByModelsSSIDs_{idx});
                    catch me %#ok
                        if bOpenMdl
                            warning(message('Simulink:Logging:DefLogSSIDRefreshFailed',...
                            this(objIdx).logAsSpecifiedByModels_{idx}));
                        end
                        continue;
                    end


                    object=get_param(blk,'Object');
                    this(objIdx).logAsSpecifiedByModels_{idx}=...
                    Simulink.SimulationData.BlockPath.manglePath(...
                    object.getFullName);


                end
            end
        end
    end

end
