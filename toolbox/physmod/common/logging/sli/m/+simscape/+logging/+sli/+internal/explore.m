function explore(simlog,source,varName)







    if nargin==1
        source=[];
    end
    if nargin==2
        varName=inputname(1);
    end
    if~isempty(source)
        [isValid,sourcePath]=simscape.logging.findPath(simlog,source);
        if~isValid
            errordlg('Node path not found');
        end
        if iscell(sourcePath)
            sourcePath=sourcePath{1};
        end
    else
        sourcePath='';
    end

    simscape.logging.internal.explore(simlog,sourcePath,varName);

end
