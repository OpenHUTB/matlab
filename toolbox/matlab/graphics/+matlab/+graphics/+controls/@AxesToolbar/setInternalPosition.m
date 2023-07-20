function setInternalPosition(obj,~)


    if isempty(obj.Parent)
        return;
    end


    if obj.Minimized
        yOffset=0;
    else
        yOffset=2;
    end




    [hCamera,aboveMatrix,hDataSpace,belowMatrix]=matlab.graphics.internal.getSpatialTransforms(obj);


    toolbarPosLowerRight=matlab.graphics.internal.transformViewerToWorld(hCamera,aboveMatrix,hDataSpace,belowMatrix,obj.ToolbarAnchorPoint');


    pos=toolbarPosLowerRight(1:2);



    obj.PixelGroup.Anchor=[pos(1),pos(2),0];


    childButtons=obj.ButtonGroup.NodeChildren;

    nButtons=length(childButtons);
    if nButtons==0
        obj.Background.Position=[0,0,0,0];
        return
    end
    buttonWidth=childButtons(end).IconWidth+2*childButtons(end).BorderWidth;
    bStart=-buttonWidth;
    paletteWidth=0;
    paletteHeight=0;

    fig=ancestor(obj,'figure');
    ref=ancestor(obj,'matlab.ui.internal.mixin.CanvasHostMixin');


    if isempty(fig)
        return;
    end

    if isa(obj.Parent,'matlab.graphics.layout.Layout')
        units=obj.Parent.Units;
        axesPixCoords=hgconvertunits(fig,obj.Parent.InnerPosition_I,units,'pixels',ref);
    elseif isa(obj.Parent,'matlab.graphics.axis.AbstractAxes')
        units=obj.Parent.Units_I;
        axesPixCoords=hgconvertunits(fig,obj.Parent.Position_I,units,'pixels',ref);
    else
        return;
    end



    hiddenIndex=-1;

    overflowBtns=0;

    overflowRows=1;

    startLeft=[];

    for i=length(childButtons):-1:1
        element=childButtons(i);


        if strcmpi(element.Tag,'overflow')
            continue;
        end


        if strcmp(element.VisibleMode,'auto')



            if~obj.isEnabledForAxes(obj.Parent,element)


                if isa(element,'matlab.ui.controls.ToolbarStateButton')&&...
                    strcmpi(element.Value,'on')
                    element.Visible_I='on';
                    paletteWidth=paletteWidth+buttonWidth;
                    paletteHeight=max(paletteHeight,buttonWidth);
                else
                    element.Visible_I='off';

                    nButtons=nButtons-1;
                end
            else

                element.Visible_I='on';
                if hiddenIndex<0
                    paletteWidth=paletteWidth+buttonWidth;
                    paletteHeight=max(paletteHeight,buttonWidth);
                end
            end
        end


        if axesPixCoords(3)-paletteWidth<buttonWidth/2

            if hiddenIndex<0
                hiddenIndex=i;



                numbuttons=(paletteWidth/buttonWidth)+1;


                if hiddenIndex>2&&~isempty(obj.OverflowButton)
                    obj.OverflowButton.Visible_I='on';
                    obj.OverflowButton.Position=[bStart-buttonWidth,-yOffset,buttonWidth,buttonWidth];
                end
            end
        else
            if~isempty(obj.OverflowButton)
                obj.OverflowButton.Visible_I='off';
            end
        end


        if strcmp(element.Visible_I,'on')


            if hiddenIndex==i&&~isempty(obj.OverflowButton)&&strcmpi(obj.OverflowButton.Visible_I,'on')
                element.Position=[bStart,-yOffset,buttonWidth,buttonWidth];

                if isempty(startLeft)
                    startLeft=bStart;
                end


            elseif hiddenIndex>2&&~isempty(obj.OverflowButton)

                if numbuttons==overflowBtns
                    overflowRows=overflowRows+1;
                    bStart=startLeft;


                    overflowBtns=0;
                end

                element.Position=[bStart-buttonWidth,...
                -yOffset-(paletteHeight*overflowRows),buttonWidth,buttonWidth];


                overflowBtns=overflowBtns+1;


                bStart=bStart+buttonWidth;


            else
                element.Position=[bStart,-yOffset,buttonWidth,buttonWidth];


                bStart=bStart-buttonWidth;
            end

            if hiddenIndex~=i&&hiddenIndex>2&&~obj.IsOpen
                element.Visible_I='off';
            end
        end




        element.BackgroundColor=double(obj.Background.Color(1:3));
    end



    if hiddenIndex<0
        obj.IsOpen=false;
    end


    if nButtons==0
        obj.Background.Position=[0,0,0,0];
        return
    end

    if~isempty(obj.OverflowButton)

        if obj.IsOpen&&strcmpi(obj.OverflowButton.Visible_I,'on')

            x=obj.OverflowButton.Position(1);
            overflowHeight=paletteHeight*overflowRows;
            y=-yOffset-overflowHeight;
            overflowWidth=overflowBtns*buttonWidth;

            obj.Background.Position=[x+yOffset,-yOffset,paletteWidth,paletteHeight];
            obj.OverflowBackground.Position=[x,y,overflowWidth,overflowHeight];
        else


            obj.IsOpen=false;
            obj.Background.Position=[-paletteWidth,-yOffset,paletteWidth,paletteHeight];

            obj.OverflowBackground.Visible='off';
            obj.OverflowButton.setOverflowIcon('collapsed');
            obj.OverflowButton.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Toolbar_ShowMore');
        end
    end

    x=obj.ToolbarAnchorPoint(1)-(paletteWidth/2);
    y=obj.ToolbarAnchorPoint(2)-(paletteHeight/2);
    obj.ToolbarMidPoint=[x,y];
    obj.togglePickable();
end
