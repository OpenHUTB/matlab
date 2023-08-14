function mustBeInertia(inertia)




    if istable(inertia)


        if isempty(inertia.Properties.RowNames)||...
            ~all(inertia.Properties.RowNames==["X";"Y";"Z"])
            error(message("aero:FixedWing:InertiaRowNamesMustBeXYZ"))
        end

        if~all(inertia.Properties.VariableNames==["X","Y","Z"])
            error(message("aero:FixedWing:InertiaVariableNamesMustBeXYZ"))
        end

        data=inertia.Variables;

    else
        data=inertia;
    end

    mustBeNumeric(data)
    mustBeReal(data)
    mustBeFinite(data)
end

