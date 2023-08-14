function out=bubblesize(varargin)

















    narginchk(0,2)
    nargs=nargin;

    usegca=false;
    if nargs>0&&isscalar(varargin{1})&&isa(varargin{1},'matlab.graphics.Graphics')
        ax=varargin{1};
        varargin=varargin(2:end);
        nargs=nargs-1;
    else
        usegca=true;
    end

    if nargs==1

        if~isnumeric(varargin{1})||~(numel(varargin{1})==2)||~(varargin{1}(2)>varargin{1}(1))...
            ||~all(isfinite(varargin{1}),'all')||~all(varargin{1}>0,'all')

            error(message('MATLAB:hg:shaped_arrays:LimitsPositive'));
        end
        if nargout~=0
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
        out=ax.HintConsumer.BubbleSizeRange;
        return
    end

    ax.HintConsumer.BubbleSizeRange=varargin{1};


end