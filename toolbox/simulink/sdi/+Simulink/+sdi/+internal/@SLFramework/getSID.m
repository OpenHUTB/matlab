function out=getSID(~,varargin)
    blk=varargin{1};
    if length(varargin)>1&&varargin{2}
        import Simulink.SimulationData.BlockPath;
        mdl=BlockPath.getModelNameForPath(blk);
        if~bdIsLoaded(mdl)
            load_system(mdl);
        end
    end
    out=Simulink.ID.getSID(blk);
end
