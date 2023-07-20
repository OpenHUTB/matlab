function blockSquarenessDiagnostic(block)












    block=strrep(block,char(10),' ');

    try
        [gl,rpi]=simscape.internal.lastTranslationResult(bdroot(block));
    catch
        error(getMessage('InvalidBlock',block));
    end


    try
        simscape.BlockSquareness(gl,rpi,block);
    catch e
        sldiagviewer.reportError(e);
        return;
    end


    sldiagviewer.reportError(getMessage('NoIssuesFound',block));
end

function msg=getMessage(varargin)

    messageCatalog='physmod:simscape:compiler:mli:diagnostics';
    msg=pm_message([messageCatalog,':',varargin{1}],varargin{2:end});
end
