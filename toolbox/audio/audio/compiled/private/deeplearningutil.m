function ok=deeplearningutil






    persistent isInstalled;
    if isempty(isInstalled)
        isInstalled=~isempty(ver('nnet'));
    end


    b=builtin('license','checkout','Neural_Network_Toolbox');
    ok=b&&isInstalled;

end