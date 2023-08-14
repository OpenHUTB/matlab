function out=addSimulinkTimeseries(this,soe,VarName,VarValue)

    out=Simulink.sdi.internal.SimOutputExplorerOutput;


    [TimeDim,SampleDims]=soe.GetTSDims(VarValue);


    out.RootSource=VarName;
    out.TimeSource=[VarName,'.Time'];
    out.DataSource=[VarName,'.Data'];
    out.TimeValues=VarValue.Time;
    out.DataValues=VarValue.Data;
    out.BlockSource=VarValue.BlockPath;
    out.ModelSource=strtok(VarValue.BlockPath,'/');
    out.SignalLabel=VarValue.Name;
    out.TimeDim=TimeDim;
    out.SampleDims=SampleDims;
    out.PortIndex=VarValue.PortIndex;
    try
        out.SID=Simulink.ID.getSID(out.BlockSource);
    catch ME %#ok


        try



            [~,modelBlocks]=find_mdlrefs(out.ModelSource,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            for i=1:length(modelBlocks)
                modelBlock=modelBlocks{i};
                if(isequal(get_param(modelBlock,'ProtectedModel'),...
                    'off'))
                    refModelName=get_param(modelBlock,'ModelName');
                    k=strfind(out.BlockSource,modelBlock);

                    if~isempty(k)
                        out.BlockSource=strrep(...
                        out.BlockSource,...
                        [modelBlock,'/'],...
                        [refModelName,'/']);
                    end
                end
            end
            out.SID=this.getSID(out.BlockSource);
        catch me %#ok
            out.SID=[];
        end
    end


    try
        hCs=getActiveConfigSet(out.ModelSource);
        hSolverConfig=hCs.getComponent('Solver');
        if strcmp(hSolverConfig.SolverType,'Variable-step')

            out.interpolation='linear';
        end
    catch me %#ok

    end
end
