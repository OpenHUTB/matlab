
function action_highlight(varargin)








    persistent current_highlight;

    mode=varargin{1};

    if strcmp(mode,'clear')

        if~isempty(current_highlight)
            for block=current_highlight

                if ishandle(block)
                    try
                        set_param(block,'HiliteAncestors','off');
                    catch Mex %#ok
                    end
                end
            end
            current_highlight=[];
        end

        action_highlight_sf('clear');

    elseif strcmp(mode,'purge')
        current_highlight=[];
        action_highlight_sf('purge');

    elseif nargin==2
        obj=varargin{2};
        set_param(obj,'HiliteAncestors',mode);
        current_highlight=[current_highlight,obj];
    end



