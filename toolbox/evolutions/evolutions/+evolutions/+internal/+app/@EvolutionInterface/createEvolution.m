function[success,outputMessage]=createEvolution(obj)




    outputMessage=struct.empty;

    currentTree=obj.TreeListManager.CurrentSelected;

    [success,output]=evolutions.internal.createEvolution(currentTree);

    if~success
        outputMessage=MException...
        ('evolutions:manage:CreateEvolutionExceptionId','%s',output.message);
    end
end

