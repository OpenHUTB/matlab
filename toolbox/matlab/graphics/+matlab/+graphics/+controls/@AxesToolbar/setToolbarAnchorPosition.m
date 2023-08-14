
function setToolbarAnchorPosition(obj,axPos,varargin)



    doMarkDirty=false;

    if isempty(varargin)
        doMarkDirty=true;
    end


    lowerMargin=2;
    toolbarHeight=18;

    canvasContainingAncestor=localGetCanvasContainingAncestor(obj);





    if isempty(canvasContainingAncestor)
        return;
    end

    [pos,units]=obj.getPositionFromCanvasContainer(canvasContainingAncestor);


    ref=ancestor(canvasContainingAncestor,'figure');

    if isempty(ref)
        return;
    end



    if isequal(ref,canvasContainingAncestor)
        ref=groot;
    end


    canvasPos=hgconvertunits(ancestor(obj,'figure'),pos,...
    units,'pixels',ref);



    upperRightAxesAnchorPoint=[axPos(1)+axPos(3),...
    axPos(2)+axPos(4)+lowerMargin+1];


    [hasScrolled,scrollPosition]=matlab.graphics.controls.ToolbarController.hasScrolled(canvasContainingAncestor);
    if any(hasScrolled)
        canvasPos(3)=canvasPos(3)+scrollPosition(1)-1;
        canvasPos(4)=canvasPos(4)+scrollPosition(2)-1;





        canvasPos(4)=canvasPos(4)-matlab.graphics.controls.ToolbarController.ASSUMED_SCROLLBAR_WIDTH;
        canvasPos(3)=canvasPos(3)-matlab.graphics.controls.ToolbarController.ASSUMED_SCROLLBAR_WIDTH;
    end




    if canvasPos(4)-upperRightAxesAnchorPoint(2)<toolbarHeight
        upperRightAxesAnchorPoint(2)=canvasPos(4)-toolbarHeight;
    end



    heightOverLap=(axPos(2)+axPos(4))-canvasPos(4);

    if heightOverLap>0
        upperRightAxesAnchorPoint(2)=upperRightAxesAnchorPoint(2)-toolbarHeight/2;
    end

    isGridLayout=isa(canvasContainingAncestor,'matlab.ui.container.GridLayout');
    ax=obj.Axes;


    if isGridLayout&&~isempty(ax)&&isa(ax.Layout,'matlab.ui.layout.GridLayoutOptions')&&~isempty(ax.Layout.Row)&&ax.Layout.Row(1)>1
        topOfAxes=axPos(2)+axPos(4);
        upperRightAxesAnchorPoint(2)=min((topOfAxes-toolbarHeight),upperRightAxesAnchorPoint(2));
    end



    if(axPos(1)+axPos(3))>canvasPos(3)
        upperRightAxesAnchorPoint(1)=canvasPos(3)-matlab.graphics.controls.ToolbarController.EDGE_PADDING;
    end

    x=upperRightAxesAnchorPoint(1);
    y=upperRightAxesAnchorPoint(2);



    obj.IsInsideAxes=y>axPos(2)&&y<=axPos(2)+axPos(4)-toolbarHeight/2&&...
    x>axPos(1)&&x<=axPos(1)+axPos(3);




    obj.ToolbarMidPoint=upperRightAxesAnchorPoint;


    obj.ToolbarAnchorPoint=upperRightAxesAnchorPoint;



    btnWidth=20;
    numBtns=numel(obj.ButtonGroup.Children);
    toolbarWidth=numBtns*btnWidth;

    if toolbarWidth>axPos(3)
        obj.createOverflowButton();
    end

    obj.setInternalPosition();

    if doMarkDirty
        obj.redrawToolbar();
    end
end

function canvasContainingAncestor=localGetCanvasContainingAncestor(target)

    canvasContainingAncestor=ancestor(target,'matlab.ui.internal.mixin.CanvasHostMixin');
    if isempty(canvasContainingAncestor)
        canvasContainingAncestor=ancestor(target,'figure');
    end
end