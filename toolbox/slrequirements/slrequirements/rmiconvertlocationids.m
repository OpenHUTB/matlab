function rmiconvertlocationids(model,docname)























    if nargin~=2||~ischar(docname)
        error(message('Slvnv:reqmgt:rmidocrename:InvalidArgumentForIds'));
    end

    try
        modelH=rmisl.getmodelh(model);
    catch Mex
        error(message('Slvnv:reqmgt:rmidocrename:NoModel',model));
    end
    if ishandle(modelH)
        [num_objects,modified,total]=rmi.docRename(modelH,docname,docname);
        disp(getString(message('Slvnv:rmidata:map:RmiDocRename',...
        num2str(num_objects),num2str(modified),num2str(total))));
    else
        error(message('Slvnv:reqmgt:rmidocrename:ResolveModelFailed',model));
    end


