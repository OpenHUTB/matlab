function Ts=ThreePhaseTapChangingTransformerInit(block,InitialTap,MinTap,MaxTap,SetSaturation,Winding2Connection,Winding3Connection,Measurements,CoreType,SpecifyInitialFluxes)


    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;
    if InitialTap<MinTap||InitialTap>MaxTap
        message=sprintf('The initial tap number must be an integer comprised between % d and %d',MinTap,MaxTap);
        Erreur.message=message;
        Erreur.identifier='SimscapePowerSystemsST:OLTCTransformer:ParameterError';
        powericon('psberror',Erreur.message,Erreur.identifier,'NoUiwait');
    end
    set_param([block,'/Three-Phase Transformer'],'SetSaturation',SetSaturation);
    set_param([block,'/Three-Phase Transformer'],'SetInitialFlux',SpecifyInitialFluxes);
    set_param([block,'/Three-Phase Transformer'],'Winding2Connection',Winding2Connection);
    if~isempty(Winding3Connection)
        set_param([block,'/Three-Phase Transformer'],'Winding3Connection',Winding3Connection);
    end
    set_param([block,'/Three-Phase Transformer'],'Measurements',Measurements);
    set_param([block,'/Three-Phase Transformer'],'CoreType',CoreType);