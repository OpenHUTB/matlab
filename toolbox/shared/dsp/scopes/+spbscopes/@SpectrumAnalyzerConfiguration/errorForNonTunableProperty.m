function errorForNonTunableProperty(obj,propertyName)




    Framework=obj.Scope.Framework;
    if~isempty(Framework)
        src=Framework.DataSource;
        if~isempty(src)
            if isRunning(src)||isPaused(src)
                throwAsCaller(MException(message('dspshared:SpectrumAnalyzer:PropertyNotTunable',propertyName)));
            end
        end
    end
end
