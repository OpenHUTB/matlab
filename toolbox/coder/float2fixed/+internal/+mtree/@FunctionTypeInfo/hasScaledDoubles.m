


function bVal=hasScaledDoubles(this)



    varInfos=this.getAllVarInfos();
    bVal=false;
    for ii=1:length(varInfos)
        var=varInfos{ii};
        if var.hasOrigScaledDouble()
            bVal=true;
            break;
        end
    end
end
