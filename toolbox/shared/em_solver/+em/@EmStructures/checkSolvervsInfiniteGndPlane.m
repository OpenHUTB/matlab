function checkSolvervsInfiniteGndPlane(obj,propVal)


















    if~isempty(getInfGPState(obj))
        if getInfGPState(obj)&&strcmpi(propVal,'FMM')
            error(message('antenna:antennaerrors:Unsupported',...
            'FMM as solver','Infinite ground plane'));
        end
    end









