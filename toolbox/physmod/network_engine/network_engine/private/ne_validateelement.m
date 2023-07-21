function ne_validateelement(item)














    fcn='simscape.compiler.mli.internal.validateMatlabModel';
    if isempty(which(fcn))
        pm_warning('physmod:network_engine:ne_validateelement:ValidationNotAvailable',item.info.SourceFile,fcn);
    else
        feval(fcn,item);
    end

end
