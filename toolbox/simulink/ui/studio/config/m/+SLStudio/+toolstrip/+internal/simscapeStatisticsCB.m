



function simscapeStatisticsCB(cbinfo,~)
    model=getfullname(cbinfo.model.handle);
    simscape.modelstatistics.open(model,true);
end
