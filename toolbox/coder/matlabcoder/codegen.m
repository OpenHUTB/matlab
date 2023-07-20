function varargout=codegen(varargin)








































































































































































































    emlcprivate('emcPtStart','total_codegen');
    c=onCleanup(@()emlcprivate('emcPtStop','total_codegen'));
    currentPath=path;
    restorePath=onCleanup(@()cleanPath(currentPath));

    for i=coder.internal.evalinArgs(varargin)
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end

    clientType='codegen';


    varargin=coder.internal.handleFloat2FixedConversion(clientType,varargin);

    report=emlcprivate('emlckernel',clientType,varargin{:});
    if nargout>0
        varargout{1}=report;
    else
        coder.internal.emcError(mfilename,report);
    end
end



function cleanPath(currentPath)



    if~isequal(currentPath,path)
        path(currentPath);
    end
end
