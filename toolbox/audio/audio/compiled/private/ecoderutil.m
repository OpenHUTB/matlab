function ok=ecoderutil

    persistent isInstalled;
    if isempty(isInstalled)
        isInstalled=~isempty(ver('embeddedcoder'));
    end
    b=builtin('license','checkout','RTW_EMBEDDED_CODER');
    ok=b&&isInstalled;

end