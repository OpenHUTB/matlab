function numModels=markModelsForPirCreation(this,level)





    numMdls=numel(this.AllModels);
    this.AllModels(numMdls).createPir=true;
    for ii=1:numMdls-1
        this.AllModels(ii).createPir=false;
    end



    for mdlIdx=numMdls:-1:2
        if this.AllModels(mdlIdx).createPir==true
            mdlName=this.AllModels(mdlIdx).modelName;
            if mdlIdx==numMdls

                if this.nonTopDut
                    startNode=this.getStartNodeName;
                else
                    startNode=this.OrigStartNodeName;
                end
                if isempty(startNode)
                    startNode=mdlName;
                end
            else
                startNode=mdlName;
            end
            mdlRefs=find_system(startNode,'LookUnderMasks','all','FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
            'BlockType','ModelReference');
            if~isempty(mdlRefs)
                configManager=this.getConfigManager(mdlName);
                this.loadConfigfiles(this.getConfigFiles,mdlName);
                for ii=1:numel(mdlRefs)
                    mdlRef=mdlRefs{ii};
                    impl=configManager.getImplementationForBlock(mdlRef);
                    if isa(impl,'hdldefaults.ModelReference')
                        isProtected=get_param(mdlRef,'ProtectedModel');
                        if strcmp(isProtected,'on')
                            continue;
                        end
                        refMdlName=get_param(mdlRef,'ModelName');




                        check=arrayfun(@(x)strcmp(x.modelName,refMdlName),...
                        this.AllModels);



                        if(isempty(find(check,1)))
                            continue;
                        end

                        if(level==2)
                            if~checkFrontEndIncrementalCodegen(this,mdlRef)
                                continue;
                            end
                        end
                        this.AllModels(check).createPir=true;

                        if~bdIsLoaded(refMdlName)
                            hdldisp(['Loading referenced model : ',refMdlName],3);
                            load_system(refMdlName);
                        end
                    end
                end
            end
        end
    end

    if(level==2)

        gp=pir;
        for ii=1:numMdls-1
            if(this.AllModels(ii).createPir==false)
                mdlName=this.AllModels(ii).modelName;
                gp.destroyPirCtx(mdlName);
                this.AllModels(ii).slFrontEnd.SimulinkConnection.termModel;
                this.AllModels(ii).slFrontEnd.SimulinkConnection.restoreParams;
            end
        end
        this.BlackBoxModels=this.AllModels(arrayfun(@(x)x.createPir==false,this.AllModels));

        topMdlName=this.AllModels(end).modelName;
        folderlink=sprintf('<a href="matlab:uiopen(''%s'');">%s</a>',...
        this.hdlGetBaseCodegendir(),this.hdlGetBaseCodegendir());
        hdldisp(message('hdlcoder:hdldisp:GenTopModel',topMdlName,folderlink));
    end


    this.AllModels=this.AllModels(arrayfun(@(x)x.createPir==true,this.AllModels));
    numModels=numel(this.AllModels);

    if(level==1)


        for ii=1:numModels
            p=pir(this.AllModels(ii).modelName);
        end
        gp=pir;
        gp.setTopPirCtx(p);
    end
end


