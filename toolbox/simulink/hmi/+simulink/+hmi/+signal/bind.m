function ret=bind(path,portIdx,varargin)



    ret=locRuntimeBind(path,portIdx,varargin{:});
end


function ret=locRuntimeBind(path,portIdx,varargin)


    ret=false;
    blockpath=Simulink.SimulationData.BlockPath(path);
    if blockpath.getLength()>0
        blk=blockpath.getBlock(1);
        mdl=Simulink.SimulationData.BlockPath.getModelNameForPath(blk);
        if bdIsLoaded(mdl)&&~strcmpi(get_param(mdl,'SimulationStatus'),'stopped')
            if nargin>2
                observer=varargin{1};
            else
                observer='dashboardblocks_observer';
            end
            simulink.hmi.signal.addRuntimeObserver(blockpath,portIdx,observer);
        end
    end
end
