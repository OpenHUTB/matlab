function[success,outputMessage]=updateEvolution(obj)




    outputMessage=struct.empty;

    currentTree=obj.TreeListManager.CurrentSelected;

    [success,output]=evolutions.internal.updateEvolution(currentTree);

    if~success
        outputString=evolutions.internal.ui.tools.createEvolutionOutputMessage(output);
        outputMessage=MException...
        ('evolutions:manage:UpdateEvolutionExceptionId','%s',output.message);
    end
end