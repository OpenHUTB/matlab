function ok=matlabcoderutil






    persistent isInstalled;
    if isempty(isInstalled)
        isInstalled=~isempty(ver('matlabcoder'));
    end


    b=builtin('license','checkout','MATLAB_CODER');
    ok=b&&isInstalled;

end