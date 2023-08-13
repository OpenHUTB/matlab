function retval=mcodeDefaultIgnoreHandle(hParent,h)


    retval=false;

    hParent=handle(hParent);
    h=handle(h);


    classname=class(h);
    if(strncmp(classname,'ui',2)||isa(h,'matlab.ui.control.Component'))&&...
        strcmpi(get(h,'HandleVisibility'),'off')
        retval=true;
    elseif~isempty(ancestor(h,'polaraxes'))

        retval=true;
    elseif~isempty(ancestor(h,'matlab.ui.control.UIAxes'))

        retval=true;
    elseif isgraphics(h,'uicontextmenu')
        retval=true;
    elseif ishghandle(h)&&localIsAxesDecoration(h)
        retval=false;


    elseif(isgraphics(hParent)...
        &&strcmp(get(hParent,'HandleVisibility'),'off')...
        &&h==hParent)
        retval=true;


    elseif isgraphics(hParent,'hggroup')||isgraphics(hParent,'hgtransform')
        if~isgraphics(hParent)
            retval=~isequal(hParent,h);
        end
    end


    function retval=localIsAxesDecoration(h)




        retval=false;

        hParent=get(h,'Parent');
        if isa(hParent,'matlab.graphics.axis.Axes')
            retval=isa(h,'specgraph.baseline')||isa(h,'matlab.graphics.axis.decorator.Baseline');
            if~retval

                labels=[hParent.XLabel_IS,hParent.ZLabel_IS,hParent.Title_IS];



                ylables=[];
                for i=1:numel(hParent.YAxis)
                    ylables=[ylables,hParent.YAxis(i).Label_IS];%#ok<AGROW,NASGU>
                end

                labels=[labels,ylables];
                retval=any(labels==h);
            end
        end
