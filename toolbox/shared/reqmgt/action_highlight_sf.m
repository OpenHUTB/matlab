function redraw=action_highlight_sf(varargin)





    persistent current_highlight_sf;

    redraw=[];

    mode=varargin{1};

    if strcmp(mode,'clear')


        if~isempty(current_highlight_sf)
            last_chart=0;
            for i=1:length(current_highlight_sf)
                if is_valid_handle(current_highlight_sf(i))
                    chart=obj_chart(current_highlight_sf(i));
                    if chart~=last_chart
                        sf('Highlight',chart,[]);
                        sf('ClearAltStyles',chart);
                        sf('Redraw',chart);
                        redraw=chart;
                        last_chart=chart;
                    end
                end
            end
            current_highlight_sf=[];
        end

    elseif strcmp(mode,'purge')

        current_highlight_sf=[];

    elseif nargin==2
        obj=varargin{2};
        redraw=sf_update_style(obj,mode);
        current_highlight_sf=[current_highlight_sf,obj];
    end
end


function result=is_valid_handle(handle)
    [isSf,objH,~]=rmi.resolveobj(handle);
    result=isSf&&~isempty(objH);
end
