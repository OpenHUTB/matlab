function out=isValidCategory(category)



    out=false;
    if strcmpi(category,'SimulinkFunction')||...
        strcmpi(category,'SubsystemFunction')
        out=true;
    end
end