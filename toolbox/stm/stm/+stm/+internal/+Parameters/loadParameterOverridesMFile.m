function paramList=loadParameterOverridesMFile(fileName)








    try
        run(fileName);
    catch
        run(which(fileName));
    end
    clear fileName;


    vars=whos;

    paramList=struct(...
    'Name',{vars.name},...
    'ClassName',{vars.class},...
    'CanShow',false,...
    'DerivedDisplayValue','');

    for k=1:length(vars)
        [paramList(k).CanShow,paramList(k).DerivedDisplayValue]=...
        stm.internal.util.getDisplayValue(eval(vars(k).name));
    end
end
