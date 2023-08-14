function chart=sf_update_style(objId,highlight)











    if nargin==2
        if ischar(highlight)
            style=sf_style(highlight);
        else
            style=highlight;
        end
    else
        style=0;
    end


    sf_set_style(objId,style);
    chart=obj_chart(objId);
    sf('Highlight',chart,[]);
    sf('Redraw',chart);
