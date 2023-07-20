function obj=setIndexNames(obj,thisNames)










    if obj.IsSubsref
        error(message('shared_adlib:OptimizationVariable:CannotOverwritePartsOfIndexNames'));
    else


        obj.IndexNamesStore=optim.internal.problemdef.validateIndexNames(thisNames,obj.Size);

    end
