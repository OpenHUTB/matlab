function commitParams(this,mdlName)




    if isempty(this.AllModels)||(this.mdlIdx==numel(this.AllModels))

        this.applyCodegenParamsFromMdl(mdlName);


        params=this.getCmdLineParams;
        if~isempty(params)&&strcmp(params{1},'HDLSubsystem')
            if~strcmp(mdlName,this.ModelName)

                params{2}=mdlName;
            end
            if isempty(params{2})


                params=params(3:end);
            end
        end
        if~isempty(params)

            this.updateParams(params);


            params=this.updateEDAScriptDefault(params);
            this.updateParams(params);
        end


        this.setNFPConfiguration();




        try
            snn=this.getStartNodeName;
            if~isempty(snn)

                find_system(snn,...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem);
            end
        catch me
            error(message('hdlcoder:validate:badDUT',snn,mdlName));
        end

        this.loadConfigfiles(this.getConfigFiles,snn);


        updateINI(this.getCPObj);
    else
        this.loadConfigfiles(this.getConfigFiles,mdlName);
    end
end


