function doUpdate(hObj,updateState)









    hCursor=hObj.Cursor;
    hTip=hObj.TipHandle;
    hLocator=hObj.LocatorHandle;

    if~isempty(hCursor)&&~isempty(hObj.DataSource)&&isvalid(hObj.DataSource)

        hTarget=hCursor.DataSource.getAnnotationTarget();
        tipPos=getLocation(hCursor.getAnchorPosition(),updateState.DataSpace,...
        updateState.TransformUnderDataSpace);

        if length(tipPos)<3
            tipPos(3)=0;
        end

        if strcmp(hObj.Visible,'on')

            visState=hTarget.Visible;

            if all(isfinite(tipPos))&&~localIsClipped(hTarget,tipPos,updateState.TransformUnderDataSpace,...
                updateState.DataSpace)
                hTip.Position=tipPos;
                hLocator.Position=tipPos;
            else

                visState='off';
            end
        else

            visState='off';
        end


        if isempty(hObj.StringUpdateStrategy)
            hObj.configureStringStrategy();
        end

        hObj.StringUpdateStrategy(hObj,hCursor,hObj.TipHandle);


        targetType='';
        if isprop(hTarget,'DisplayName_I')

            targetType=hTarget.DisplayName_I;
        end
        if isempty(targetType)

            targetType=[getString(message('MATLAB:uistring:datacursor:Type'))...
            ,' '...
            ,localGetShortClassName(hTarget)];
        end
        hTip.TargetType=targetType;


        localUpdateInterpolateValue(hObj);
    else
        visState='off';
    end




    if strcmpi(visState,'off')
        hTip.Visible=visState;
        hLocator.Visible=visState;
    else
        switch(hObj.DataTipStyle)
        case matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly
            hTip.Visible='off';
            hLocator.Visible='on';
        case matlab.graphics.shape.internal.util.PointDataTipStyle.TipOnly
            hTip.Visible='on';
            hLocator.Visible='off';
        case matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip
            hTip.Visible='on';
            hLocator.Visible='on';
        end
    end



    hTip.Selected=hObj.Selected;
    hTip.SelectionHighlight=hObj.SelectionHighlight;



    if isprop(hTip,'CurrentTip')
        hTip.CurrentTip=hObj.CurrentTip;
    end


    hTip.LocatorSize=hObj.MarkerSize;

    hObj.updateParentLayerIfNeeded();


    if isempty(hObj.MarkedCleanListener)
        hObj.MarkedCleanListener=event.listener(hObj,'MarkedClean',@oneShotMarkedCleanListener);
    else
        hObj.MarkedCleanListener.Enabled=true;
    end


end

function oneShotMarkedCleanListener(hObj,~)


    matlab.graphics.shape.internal.DataTipController.updateContextMenuIfNeeded(hObj);
    hObj.MarkedCleanListener.Enabled=false;
end

function localUpdateInterpolateValue(hObj)
    hAx=hObj.Parent;
    if~isempty(hAx)&&isa(hAx,'matlab.graphics.axis.AbstractAxes')&&~isempty(hAx.Interactions)
        ind=arrayfun(@(x)isa(x,'matlab.graphics.interaction.interactions.DataTipInteraction'),hAx.Interactions);

        if~isempty(hAx.Interactions(ind))
            interpVal=hObj.Interpolate;%#ok<NASGU>
            if strcmpi(hAx.Interactions(ind).SnapToDataVertex,'on')
                interpVal='off';
            else
                interpVal='on';
            end


            if~isequal(hObj.Interpolate,interpVal)
                hObj.Interpolate=interpVal;
            end
        end
    end
end

function ret=localIsClipped(obj,pt,tform,ds)


    if isprop(obj,'Clipping')&&strcmp(obj.Clipping,'off')
        ret=false;
    else
        hAx=ancestor(obj,'matlab.graphics.axis.AbstractAxes','node');
        if isempty(hAx)||strcmp(hAx.Clipping,'off')
            ret=false;
        else

            X=[pt(:);1];
            X2=tform*X;
            pt=X2(1:3)./X2(4);

            ret=isClipped(hAx,pt,ds);
        end
    end
end

function name=localGetShortClassName(hData)

    cls=metaclass(hData);
    name=cls.Name;
    pkg=cls.ContainingPackage;

    if~isempty(pkg)

        pkgname=pkg.Name;

        name=name(numel(pkgname)+2:end);
    end
end