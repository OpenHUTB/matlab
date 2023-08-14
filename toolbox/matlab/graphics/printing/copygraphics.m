function copygraphics(varargin)




































































    if~matlab.graphics.internal.export.isClipboardSupported
        error(message('MATLAB:print:ClipboardNotSupported'));
    end
    try
        p=matlab.graphics.internal.export.exportAPIArgumentParser;
        p=p.parseArgs('clipboard',varargin{:});
        inputArgs=p.convertToInternalAPI;
        restoreBacktrace=...
        matlab.graphics.internal.export.Exporter.disableWarningBacktrace;%#ok<NASGU>
        p.warnIfNeeded();
        matlab.graphics.internal.export.exportTo(inputArgs{:});
    catch ex
        throw(ex);
    end
end
