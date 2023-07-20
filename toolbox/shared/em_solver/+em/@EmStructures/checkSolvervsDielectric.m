function checkSolvervsDielectric(obj,propVal)
    if~strcmpi(propVal,'MoM')
        if isa(obj,'em.Antenna')||isa(obj,'em.Array')||isa(obj,'installedAntenna')
            I=info(obj);
            if strcmpi(I.HasSubstrate,"true")&&~isequal(obj.Substrate.EpsilonR,1)
                error(message('antenna:antennaerrors:Unsupported',...
                'Object with dielectric materials','for analysis with the PO or FMM solvers. Switch ''Solver'' to MoM'));
            end
        end
    end