function checkPhaseShift(obj,numelements)
    if isscalar(obj.PhaseShift)
        setPhaseShift(obj,obj.PhaseShift.*pi/180,numelements);
    else
        validateattributes(obj.PhaseShift,{'numeric'},...
        {'numel',numelements},class(obj),'PhaseShift');
        setPhaseShift(obj,obj.PhaseShift.*pi/180);
    end
end