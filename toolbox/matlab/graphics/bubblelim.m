function out=bubblelim(varargin)

























    narginchk(0,2)
    nargs=nargin;

    usegca=false;
    if nargin>0&&isscalar(varargin{1})&&isa(varargin{1},'matlab.graphics.Graphics')
        ax=varargin{1};
        varargin=varargin(2:end);
        nargs=nargs-1;
    else
        usegca=true;
    end

    if nargs==1

        if isnumeric(varargin{1})
            try
                hgcastvalue('matlab.graphics.datatype.LimitsWithInfs',varargin{1});
            catch
                error(message('MATLAB:hg:shaped_arrays:LimitsPredicate'));
            end
        elseif matlab.graphics.internal.isCharOrString(varargin{1})
            if~(strcmpi(varargin{1},'mode')||strcmpi(varargin{1},'auto')||...
                strcmpi(varargin{1},'manual'))

                error(message('MATLAB:rulerFunctions:InvalidLimitsMode'));
            end
        else
            error(message('MATLAB:hg:shaped_arrays:LimitsPredicate'));
        end

        if nargout~=0&&~strcmpi(varargin{1},'mode')
            error(message('MATLAB:nargoutchk:tooManyOutputs'));
        end
    elseif nargs>1
        error(message('MATLAB:narginchk:tooManyInputs'));
    end

    if usegca
        ax=gca;
    end
    if~isa(ax,'matlab.graphics.axis.AbstractAxes')
        error(message('MATLAB:Chart:UnsupportedConvenienceFunction','bubblesize',ax.Type))
    end

    if nargs==0
        out=ax.HintConsumer.BubbleSizeLimits;
        return
    elseif strcmpi(varargin{1},'mode')
        out=ax.HintConsumer.BubbleSizeLimitsMode;
        return
    end

    if isnumeric(varargin{1})
        ax.HintConsumer.BubbleSizeLimits=varargin{1};
    else
        ax.HintConsumer.BubbleSizeLimitsMode=varargin{1};
    end



end