function scroll(this,varargin)











    if strcmp(this.Scrollable,'off')
        warning(message('MATLAB:uicontainer:ScrollableOff'));
        return;
    end

    narginchk(2,3);

    if length(varargin)==1
        if isnumeric(varargin{1})&&length(varargin{1})==2
            this.ScrollableViewportLocation=varargin{1};
        elseif isValidScrollTarget(varargin{1})
            this.scrollTo(varargin{1});
        elseif isscalar(varargin{1})&&ishghandle(varargin{1})
            target=varargin{1};
            parent=target.Parent;
            scrollCalls={};
            while~isempty(parent)&&target~=this
                if isprop(parent,'Scrollable')
                    scrollCalls{end+1}={parent,target.Position(1:2)};
                end
                target=parent;
                parent=target.Parent;
            end
            if target~=this


                error(message('MATLAB:uicontainer:InvalidScrollTarget'));
            else
                for i=1:length(scrollCalls)
                    call=scrollCalls{i};
                    scroll(call{1},call{2});
                end
            end
        else
            error(message('MATLAB:uicontainer:InvalidScrollTarget'));
        end
    elseif length(varargin)==2
        if cellfun(@isnumeric,varargin)
            this.ScrollableViewportLocation=[varargin{1:2}];
        elseif cellfun(@(x)ischar(x)||isstring(x),varargin)
            if isValidScrollTargetPair(varargin(1:2))



                this.scrollTo(varargin(1:2));
            else
                error(message('MATLAB:uicontainer:InvalidScrollTarget'));
            end
        end
    end
end

function isH=isHorizontalScrollTarget(scrollTarget)
    isH=strcmp(scrollTarget,'left')||strcmp(scrollTarget,'right');
end

function isV=isVerticalScrollTarget(scrollTarget)
    isV=strcmp(scrollTarget,'bottom')||strcmp(scrollTarget,'top');
end

function isValid=isValidScrollTarget(scrollTarget)
    isValid=(ischar(scrollTarget)||isstring(scrollTarget))&&...
    (isHorizontalScrollTarget(scrollTarget)||isVerticalScrollTarget(scrollTarget));
end

function isValid=isValidScrollTargetPair(scrollTargetPair)
    isValid=numel(scrollTargetPair)==2&&...
    (isVerticalScrollTarget(scrollTargetPair{1})&&...
    isHorizontalScrollTarget(scrollTargetPair{2}))||...
    (isVerticalScrollTarget(scrollTargetPair{2})&&...
    isHorizontalScrollTarget(scrollTargetPair{1}));
end

