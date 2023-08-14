function obj=update(obj,name,rename)




    if isempty(obj)
        return
    end

    switch class(obj)
    case "Aero.FixedWing.Coefficient"



        if(~rename)
            return
        end

        [stateOutputs,stateVariables]=find(obj.isLT);
        for i=1:numel(stateOutputs)
            appendCoefficientToLTStructInfo(obj.Values{stateOutputs(i),stateVariables(i)},join([name,obj.StateOutput(stateOutputs(i)),obj.StateVariables(stateVariables(i))],"_"));
        end
    case "Aero.FixedWing.Thrust"
        coeffs=arrayfun(@(c)Aero.FixedWing.internal.update(c.Coefficients,join([name,c.Properties.Name],"_"),rename),obj,"UniformOutput",false);
        [obj.Coefficients]=coeffs{:};

    case "Aero.FixedWing.Surface"
        coeffs=arrayfun(@(c)Aero.FixedWing.internal.update(c.Coefficients,join([name,c.Properties.Name],"_"),rename),obj,"UniformOutput",false);
        [obj.Coefficients]=coeffs{:};

        surfs=arrayfun(@(s)Aero.FixedWing.internal.update(s.Surfaces,join([name,s.Properties.Name],"_"),rename),obj,'UniformOutput',false);
        [obj.Surfaces]=surfs{:};
    case "Aero.FixedWing"
        obj.Coefficients=Aero.FixedWing.internal.update(obj.Coefficients,join([name,obj.Properties.Name],"_"),rename);
        [obj.Surfaces]=Aero.FixedWing.internal.update(obj.Surfaces,join([name,obj.Properties.Name],"_"),rename);
        [obj.Thrusts]=Aero.FixedWing.internal.update(obj.Thrusts,join([name,obj.Properties.Name],"_"),rename);
    end
end

function appendCoefficientToLTStructInfo(LT,combinedName)
    LT.StructTypeInfo.Name=combinedName;
end

