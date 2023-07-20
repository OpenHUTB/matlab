function displayAllowed=allowsDisplay(options)







    StructHasDisplayOption=isstruct(options)&&isfield(options,'Display');
    HasDisplayOption=StructHasDisplayOption||isa(options,'optim.options.SolverOptions');
    displayAllowed=~HasDisplayOption||~any(strcmp(options.Display,{'none','off'}));

end