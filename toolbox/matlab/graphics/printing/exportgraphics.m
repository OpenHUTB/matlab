function exportgraphics(varargin)























































































    try
        p=matlab.graphics.internal.export.exportAPIArgumentParser;
        p=p.parseArgs('file',varargin{:});
        inputArgs=p.convertToInternalAPI;
        restoreBacktrace=...
        matlab.graphics.internal.export.Exporter.disableWarningBacktrace;%#ok<NASGU>
        p.warnIfNeeded();
        matlab.graphics.internal.export.exportTo(inputArgs{:});
    catch ex
        throw(ex)
    end
end
