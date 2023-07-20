%#codegen


function z=dts_eye(varargin)
    coder.allowpcode('plain');
    coder.internal.allowHalfInputs;
    eml_prefer_const('varargin');
    coder.inline('always');

    if nargin>1
        if nargin>=2
            sentinel=varargin{end-1};
            if ischar(sentinel)&&eml_is_const(sentinel)&&strcmp(sentinel,'like')

                if isa(varargin{end},'double')
                    z=eye(varargin{1:end-2},'single');
                else
                    z=eye(varargin{:});
                end
                return;
            end
        else
        end
        if ischar(varargin{end})
            if strcmp(varargin{end},'double')
                z=eye(varargin{1:end-1},'single');
            else
                z=eye(varargin{:});
            end
        else
            z=eye(varargin{:},'single');
        end
    else
        z=single(eye(varargin{:}));
    end
end
