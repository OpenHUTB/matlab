function refresh(name)




    if~isempty(which('simscape.modelstatistics.open'))
        updateModel=true;
        simscape.modelstatistics.open(name,true,updateModel);
    end

end
