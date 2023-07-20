function UnfoldingVerbose(obj,forDebug,text,varargin)



    if(obj.Verbose&&~forDebug)||(obj.Debugging&&~forDebug)
        if nargin==3
            fprintf('%s\n',text);
        else
            fprintf('%s ... ',text);
        end
    elseif(obj.Verbose&&forDebug&&obj.Debugging)||(obj.Debugging&&forDebug)
        if nargin==3
            fprintf('...... %s\n',text);
        else
            fprintf('...... %s ... ',text);
        end
    end


