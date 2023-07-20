function checkLattice(obj)
    if~isscalar(obj.ColumnSpacing)
        if strcmpi(obj.Lattice,'Triangular')
            error(message('antenna:antennaerrors:NonUniformSpacingNotAllowed',obj.Lattice));
        end
    end
end