function report=generateSimscape(varargin)







    if nargin<1
        return;
    end
    if~ischar(varargin{end})
        return;
    end
    if~strcmp(varargin{end},'tpb3379334_563d_4394_b05f_26c58924749e')
        return;
    end


    for i=1:coder.internal.evalinArgs(varargin)
        try
            varargin{i}=evalin('caller',varargin{i});
        catch
        end
    end


    report=emlcprivate('callfcn','emlckernel','simscape',varargin{1:end-1});

end
