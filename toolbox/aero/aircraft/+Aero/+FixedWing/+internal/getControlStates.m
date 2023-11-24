function ctrlState=getControlStates(obj)

    if obj.Controllable
        switch obj.Symmetry
        case "Symmetric"

            prop=Aero.Aircraft.Properties(1,"Name",obj.Properties.Name);
            ctrlState=Aero.Aircraft.ControlState(1,"Properties",prop,...
            "MaximumValue",obj.MaximumValue,"MinimumValue",obj.MinimumValue);

        case "Asymmetric"

            ctrlState=Aero.Aircraft.ControlState(1,3,...
            "MaximumValue",obj.MaximumValue,"MinimumValue",obj.MinimumValue);
            ctrlState(1).Properties.Name=obj.ControlVariables(1);
            ctrlState(2).Properties.Name=obj.ControlVariables(2);
            ctrlState(3).Properties.Name=obj.Properties.Name;
            ctrlState(3).Settable="off";
            ctrlState(3).DependsOn=fliplr(obj.ControlVariables);
        end

        if class(obj)=="Aero.FixedWing.Thrust"
            [ctrlState.DeflectionAngle]=false;
        end

    else
        ctrlState=Aero.Aircraft.ControlState(0);
    end
end