function validComponentNames=getValidComponentNames(obj)




    if numel(obj)>1
        validComponentNames=arrayfun(@Aero.Aircraft.internal.validation.getValidComponentNames,obj,"UniformOutput",false);
        validComponentNames=string(horzcat(validComponentNames{:}));
        return
    end
    if isempty(obj)
        validComponentNames=string([]);
        return
    end

    validComponentNames=obj.Properties.Name;

    switch class(obj)
    case "Aero.FixedWing.Coefficient"


    case "Aero.FixedWing.Thrust"


        if(obj.Properties.Name==obj.Coefficients.Properties.Name)
            validComponentNames=obj.Properties.Name;
        else
            validComponentNames=[validComponentNames,Aero.Aircraft.internal.validation.getValidComponentNames(obj.Coefficients)];
        end

    case "Aero.FixedWing.Surface"

        surfValidNames=arrayfun(@Aero.Aircraft.internal.validation.getValidComponentNames,obj.Surfaces,"UniformOutput",false);

        validComponentNames=[validComponentNames,string(horzcat(surfValidNames{:}))];

    case "Aero.FixedWing"
        surfValidNames=arrayfun(@Aero.Aircraft.internal.validation.getValidComponentNames,obj.Surfaces,"UniformOutput",false);
        thrustValidNames=arrayfun(@Aero.Aircraft.internal.validation.getValidComponentNames,obj.Thrusts,"UniformOutput",false);

        validComponentNames=[validComponentNames,string(horzcat(surfValidNames{:},thrustValidNames{:}))];
    end

end