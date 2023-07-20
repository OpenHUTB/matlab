function[success,outputMessage]=getEvolution(obj,evolutionInfo)




    outputMessage=struct.empty;

    currentTree=obj.TreeListManager.CurrentSelected;

    [success,output]=evolutions.internal.getEvolution(currentTree,evolutionInfo);

    if~success
        outputMessage=MException...
        ('evolutions:manage:GetEvolutionExceptionId','%s',output.message);
    end
end