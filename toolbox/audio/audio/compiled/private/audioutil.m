function ok=audioutil







    persistent isInstalled;
    if isempty(isInstalled)
        isInstalled=~isempty(ver('audio'));
    end


    b=builtin('license','checkout','Audio_System_Toolbox');
    ok=b&&isInstalled;

end
