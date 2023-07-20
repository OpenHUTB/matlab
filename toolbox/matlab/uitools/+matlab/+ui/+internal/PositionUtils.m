classdef(Abstract,Sealed,Hidden)PositionUtils<handle





    methods(Static)
        function out=getDevicePixelPosition(h)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            out=get(h,'Position');
        end

        function out=getDevicePixelOuterPosition(h)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            out=get(h,'OuterPosition');
        end

        function out=getDevicePixelInnerPosition(h)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            out=get(h,'InnerPosition');
        end

        function out=getDevicePixelExtent(h)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            out=get(h,'Extent');
        end

        function setDevicePixelPosition(h,value)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            set(h,'Position',value);
        end

        function setDevicePixelOuterPosition(h,value)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            set(h,'OuterPosition',value);
        end

        function setDevicePixelInnerPosition(h,value)


            c=changeUnitsToDevicePixelsScopeGuard(h);%#ok<NASGU>
            set(h,'InnerPosition',value);
        end

        function out=getDevicePixelScreenSize()


            c=changeUnitsToDevicePixelsScopeGuard(groot);%#ok<NASGU>
            out=get(groot,'ScreenSize');
        end

        function out=getDevicePixelPositionRelativeToFigure(h)



            pixelPos=getpixelposition(h,true);
            f=ancestor(h,'figure');
            out=hgconvertunits(f,pixelPos,'pixels','devicepixels',get(f,'Parent'));
        end

        function out=getPixelRectangleInDevicePixels(rect,fig)


            out=hgconvertunits(fig,rect,'pixels','devicepixels',get(fig,'Parent'));
        end

        function out=getPixelRectangleInPlatformPixels(rect,fig)


            out=hgconvertunits(fig,rect,'pixels',matlab.ui.internal.PositionUtils.getPlatformPixelUnits(),get(fig,'Parent'));
        end

        function out=getPlatformPixelRectangleInPixels(rect,fig)


            out=hgconvertunits(fig,rect,matlab.ui.internal.PositionUtils.getPlatformPixelUnits(),'pixels',get(fig,'Parent'));
        end

        function out=getPlatformPixelPosition(h)


            c=changeUnitsToPlatformPixelsScopeGuard(h);%#ok<NASGU>
            out=get(h,'Position');
        end

        function u=getPlatformPixelUnits()






            u='devicepixels';
            if ismac()
                u='pixels';
            end
        end

        function fitToContent(fig,varargin)









            narginchk(1,2);


            isUIFigure=matlab.ui.internal.isUIFigure(fig);
            if~isUIFigure
                ex=MException(message('MATLAB:ui:uifigure:UnsupportedAppDesignerFunctionality','figure'));
                throwAsCaller(ex);
            end

            if nargin==1

                anchor='center';
            else
                anchor=varargin{1};
            end

            anchor=convertStringsToChars(anchor);

            if~isValidAnchor(anchor)
                ex=MException(message('MATLAB:Figure:InvalidFitToContentAnchor'));
                throwAsCaller(ex);
            end



            hasGrid=any(arrayfun(@(x)isa(x,'matlab.ui.container.GridLayout'),fig.Children));
            if~hasGrid

                warning(message('MATLAB:Figure:FitToContentCalledWithNoGrid'));
                return;
            end





            drawnow nocallbacks;

            fig.fitToContentWithAnchor(anchor);
        end


    end

end

function c=changeUnitsScopeGuard(h,units)
    unitsProp='Units_I';
    origUnits=get(h,unitsProp);
    set(h,unitsProp,units);
    c=onCleanup(@()set(h,unitsProp,origUnits));
end

function c=changeUnitsToDevicePixelsScopeGuard(h)
    c=changeUnitsScopeGuard(h,'devicepixels');
end

function c=changeUnitsToPlatformPixelsScopeGuard(h)
    c=changeUnitsScopeGuard(h,matlab.ui.internal.PositionUtils.getPlatformPixelUnits());
end

function isValid=isValidAnchor(anchor)


    try
        validateattributes(anchor,...
        {'char'},...
        {'row'});
    catch ME %#ok<NASGU>
        isValid=false;
        return;
    end

    isValid=strcmp(anchor,'center')||strcmp(anchor,'topleft');
end
