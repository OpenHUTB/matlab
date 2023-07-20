function blks=findTimeVaryingSources(model,varargin)


























    ModelParameterMgr=slcontrollib.internal.mdlcfg.ParameterManager(model);
    ModelParameterMgr.loadModels;
    iscompiled=any(strcmp(get_param(model,'SimulationStatus'),{'paused','running'}));


    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    if~iscompiled
        ModelParameterMgr.prepareForFrestimate;
    end
    models=getUniqueNormalModeModels(ModelParameterMgr);

    if nargin>1

        var=varargin{1};
        if isa(var,'linearize.IOPoint')
            io=var;
            [io,invalidIO]=linearize.checkModelIOPoints(models,io);
            if~isempty(invalidIO)

                LocalRestore(ModelParameterMgr,iscompiled);
                MSLException(message('Slcontrol:frest:FindSourcesNonExistentIO',...
                invalidIO(1).PortNumber,invalidIO(1).Block)).throw();
            end
        else

            LocalRestore(ModelParameterMgr,iscompiled);
            ctrlMsgUtils.error('Slcontrol:frest:FindSourcesInvalidIO');
        end
    else
        io=linearize.getModelIOPoints(models);
    end

    mdlobj=get_param(model,'Object');

    iostruct=[];

    for ct=1:numel(io)
        if any(strcmp(io(ct).Type,...
            {'output','openoutput',...
            'sensitivity','breakinputoutput',...
            'compsensitivity','looptransfer'}))
            iostruct(end+1).Block=io(ct).Block;
            iostruct(end).Port=io(ct).PortNumber;
        end
    end

    if isempty(iostruct)
        ctrlMsgUtils.warning('Slcontrol:frest:FindSourcesNoOutputIO');
        rawblks=[];
    else

        rawblks=mdlobj.getTimeVaryingSourceBlocks(iostruct);
    end


    LocalRestore(ModelParameterMgr,iscompiled);


    if isempty(rawblks)

        blks=[];
    else
        for ct=1:numel(rawblks)
            blks(ct)=Simulink.BlockPath(rawblks{ct});
        end
    end
end

function LocalRestore(mmgr,iscompiled)

    if~iscompiled
        mmgr.restoreModels;
        mmgr.closeModels;
    end
end

