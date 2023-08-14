function applyCodegenParamsFromMdl(this,mdlName)


    cli=this.getCLI;
    params=this.getModelParams(mdlName);
    params=cli.removeTransientParams(params);
    params=this.updateEDAScriptDefault(params);

    if~isempty(params)


        for itr=1:2:length(params)
            try
                cli.set(params{itr},params{itr+1});
            catch mEx
                switch(mEx.identifier)
                case{'MATLAB:noSuchMethodOrField','MATLAB:class:InvalidProperty'}






                otherwise
                    rethrow(mEx)
                end
            end
        end
    end




    snn=cli.HDLSubsystem;
    if~isempty(snn)
        if this.DUTMdlRefHandle>0
            snn=mdlName;
            cli.HDLSubsystem=snn;
        else
            [snnMdlName,rest]=strtok(snn,'/');
            if~isempty(snnMdlName)&&~strcmpi(mdlName,snnMdlName)
                snn=[mdlName,rest];
                cli.HDLSubsystem=snn;
            end
        end
    end
end
