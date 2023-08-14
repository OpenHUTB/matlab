function compName=getCompName(this,hC,opName)



    if~isempty(hC.Name)
        compName=hC.Name;
    else
        compName=opName;
    end

end
