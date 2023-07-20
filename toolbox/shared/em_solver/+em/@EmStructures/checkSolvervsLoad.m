function checkSolvervsLoad(obj,propVal)
    if~any(strcmpi(propVal,{'MoM','MoM-PO'}))
        if isa(obj,'em.Antenna')||isa(obj,'em.Array')
            I=info(obj);
            if strcmpi(I.HasLoad,"true")
                error(message('antenna:antennaerrors:Unsupported',...
                'Object with load','analysis with the PO or FMM solvers. Switch ''Solver'' to MoM'));
            end
        elseif isa(obj,'installedAntenna')
            I=info(obj);
            if strcmpi(I.HasLoad,"true")
                error(message('antenna:antennaerrors:Unsupported',...
                'Object with load','analysis with the PO or FMM solvers. Switch ''Solver'' to MoM or MoM-PO'));
            end
        end
    end