classdef(Abstract,Sealed)GetPixelPositionHelper




    properties(Constant)


        pixOrigin=1;
    end

    methods(Static)
        function position=getPixelPositionHelper(h,recursive)


            parent=getparent(h);


            figHandle=ancestor(h,'figure');
            isUIFigure=matlab.ui.internal.isUIFigure(figHandle);

            try
                if~isempty(parent)&&isprop(h,'Position')
                    position=get(h,'Position');

                    assert(length(position)==4);
                else
                    position=[0,0,0,0];
                    return;
                end
                if isprop(h,'Units')


                    curr_units=get(h,'Units');
                    if~strcmp(curr_units,'pixels')



                        position=hgconvertunits(figHandle,position,curr_units,...
                        'Pixels',parent);
                    end
                end
            catch ME %#ok<NASGU>

                position=[0,0,0,0];
            end

            if recursive&&~ishghandle(h,'figure')&&~ishghandle(parent,'figure')
                offset=matlab.ui.internal.GetPixelPositionHelper.getPixelPositionOffsetOneLevel(parent,isUIFigure);
                parentPos=getpixelposition(parent,recursive)-matlab.ui.internal.GetPixelPositionHelper.pixOrigin;
                position=position+[parentPos(1:2),0,0]+[offset,0,0];
            end
        end

        function offset=getPixelPositionOffsetOneLevel(parent,isUIFigure)
            if isprop(parent,'Scrollable')&&parent.Scrollable
                scrollLocOffset=parent.ScrollableViewportLocation-matlab.ui.internal.GetPixelPositionHelper.pixOrigin;

                offset=-scrollLocOffset;
            else
                offset=[0,0];
            end


            if(isa(parent,'matlab.ui.container.Panel'))
                offset=offset+matlab.ui.internal.getPanelMargins(parent);
            elseif(isUIFigure)
                if(isa(parent,'matlab.ui.container.TabGroup'))




                    offset=offset+[1,1];
                elseif(isa(parent,'matlab.ui.container.Tab'))

                    offset=offset+matlab.ui.internal.getTabMargins(parent);
                end
            end
        end
    end
end

function parent=getparent(h)
    parent=get(h,'parent');
    if~isempty(parent)&&~isgraphics(parent,'Root')&&...
        ~isa(parent,'matlab.ui.internal.mixin.CanvasHostMixin')&&...
        ~isa(parent,'matlab.ui.container.TabGroup')





        parent=ancestor(parent,'matlab.ui.internal.mixin.CanvasHostMixin');
    end
end
