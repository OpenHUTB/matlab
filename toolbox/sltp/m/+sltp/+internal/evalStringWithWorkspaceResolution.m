function varargout=evalStringWithWorkspaceResolution(mdl,nothrow,varargin)
    n=nargin-2;
    assert(nargout==n);
    mdlWS=get_param(mdl,'ModelWorkspace');
    mdlWSDirty=mdlWS.isDirty;
    cu=onCleanup(@()set(mdlWS,'isDirty',mdlWSDirty));
    varargout=cell(1,n);
    for i=1:n
        inStr=varargin{i};
        tempResult=[];
        try
            tempResult=evalin(mdlWS,inStr);
        catch E %#ok            
            try
                tempResult=evalin('base',inStr);
            catch E1 %#ok                
                try
                    tempResult=sltp.internal.evalStringInDataDictionary(mdl,inStr);
                catch E2
                    if~nothrow
                        throw(E);
                    end
                end
            end
        end

        if isa(tempResult,'Simulink.Parameter')
            tempResult=tempResult.Value;
        end

        varargout{i}=tempResult;
    end

end