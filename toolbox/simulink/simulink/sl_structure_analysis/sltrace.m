function varargout=sltrace(varargin)



















































    import sltrace.*;
    import sltrace.utils.*;


    if nargout>1
        error(message('Simulink:HiliteTool:TooManyOutputArguments'));
    end


    if nargin<1
        error(message('Simulink:HiliteTool:NotEnoughInputArguments'));
    end



    try
        if isa(varargin{1},'Simulink.BlockPath')
            blockPath=varargin{1};
            validate(blockPath);
            traceType=class(blockPath);
            traceObj=blockPath.getBlock(blockPath.getLength);
        else
            traceObj=convertStringsToChars(varargin{1});
            traceType=get_param(traceObj,'Type');
        end

        if isempty(traceObj)
            error(message('Simulink:HiliteTool:InvalidTraceObject'));
        end
    catch ME
        if strcmp(ME.identifier,'SimulationData:Objects:InvalidBlockPathInvalidBlock')
            throw(ME);
        end
        error(message('Simulink:HiliteTool:InvalidTraceObject'));
    end


    if nargin==1&&~strcmp(traceType,'port')
        error(message('Simulink:HiliteTool:NotEnoughInputArguments'));
    end



    if nargin>1&&strcmp(convertStringsToChars(lower(varargin{2})),'clear')
        if nargout>0
            error(message('Simulink:HiliteTool:TooManyOutputArguments'));
        end
        try
            if~strcmp(traceType,'block_diagram')
                baseGraph=sltrace.utils.getBaseGraph(traceObj);
                BD=get_param(baseGraph,'handle');
            else
                BD=get_param(varargin{1},'handle');
            end
            sltrace.internal.HighlightManager.RemoveHighlight(BD);
        catch
            error(message('Simulink:HiliteTool:InvalidModelToClear',traceObj));
        end
        return;
    end



    try
        varargout{1}=sltrace.Graph(traceType,varargin{:});
    catch ME
        throw(ME);
    end
end

