function tableRowValidation(obj,T)

    switch obj.ReferenceFrame
    case "Body"
        rows="C"+["X";"Y";"Z";"l";"m";"n"];
    case "Wind"
        rows="C"+["D";"Y";"L";"l";"m";"n"];
    case "Stability"
        rows="C"+["D";"Y";"L";"l";"m";"n"];
    end
    mustBeMember(T.Properties.RowNames,rows)
end
