
function installed=isCompilerInstalled()
    installed=false;
    c=mex.getCompilerConfigurations();
    for i=1:numel(c)
        if strcmpi(c(i).Language,'C')||strcmpi(c(i).Language,'C++')
            installed=true;
            return
        end
    end
end
