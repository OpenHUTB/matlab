function[position,moveOnResize]=getPositionForSpec(positionSpec)

    if~(isa(positionSpec,'Simulink.output.PositionSpecification'))
        error(message('sl_diagnostic:SLMsgVieweri18N:CompositeDVWidgetInvalidPositionSpec').getString());
    end

    p1=positionSpec.getTopLeftCorner();
    p2=positionSpec.getBottomRightCorner();
    RectangleWidth=positionSpec.getRectangleWidth();
    RectangleHeight=positionSpec.getRectangleHeight();
    prefSide=positionSpec.getPreferredSide();

    WidgetWidth=450;
    WidgetHeight=250;
    WidgetSize=[WidgetWidth,WidgetHeight];
    screenInfo=get(0,'MonitorPositions');


    TL=p1;
    TR=[p1(1)+RectangleWidth,p1(2)];
    BR=p2;
    BL=[p1(1),p1(2)+RectangleHeight];

    cornerScreenIndex=cellfun(@(x)getScreenIndexForPoint(x),{TL,TR,BR,BL});



    if(nnz(cornerScreenIndex)==0)
        pointerXY=get(0,'PointerLocation');
        screenIndex=getScreenIndexForPoint(pointerXY);


        if isequal(screenIndex,0)
            screenIndex=1;
        end
        targetScreen=screenInfo(screenIndex,:);
        position=targetScreen(3:4)/2-WidgetSize/2;
        moveOnResize=false;
        return;
    end







    placed=false;
    moveOnResize=false;
    switch prefSide
    case Simulink.output.utils.PreferredSide.TOP
        placed=tryPlacingOnTop()||tryPlacingOnLeft()||tryPlacingOnRight()||tryPlacingOnBottom();
    case Simulink.output.utils.PreferredSide.LEFT
        placed=tryPlacingOnLeft()||tryPlacingOnTop()||tryPlacingOnBottom()||tryPlacingOnRight();
    case Simulink.output.utils.PreferredSide.RIGHT
        placed=tryPlacingOnRight()||tryPlacingOnTop()||tryPlacingOnBottom()||tryPlacingOnLeft();
    case Simulink.output.utils.PreferredSide.BOTTOM
        placed=tryPlacingOnBottom()||tryPlacingOnLeft()||tryPlacingOnRight()||tryPlacingOnTop();
    end


    if~placed
        validIdx=find(cornerScreenIndex);
        currentScreen=screenInfo(cornerScreenIndex(validIdx(1)),:);
        position=currentScreen(3:4)/2-WidgetSize/2;
    end


    function placed=tryPlacingOnTop()
        placed=false;


        xy1=[TL(1),TL(2)-WidgetHeight];
        xy2=xy1+WidgetSize;
        xy1ScreenIndex=getScreenIndexForPoint(xy1);

        if(xy1ScreenIndex>0)

            if(xy1ScreenIndex==getScreenIndexForPoint(xy2))
                position=xy1;
                moveOnResize=true;
                placed=true;
            else



                currentScreen=screenInfo(xy1ScreenIndex,:);
                xy3=[min(currentScreen(1)+currentScreen(3)-1,xy1(1)+WidgetWidth)-WidgetWidth,xy1(2)];
                xy4=xy3+WidgetSize;
                xy3ScreenIndex=getScreenIndexForPoint(xy3);

                if(xy3ScreenIndex>0&&xy3ScreenIndex==getScreenIndexForPoint(xy4))
                    position=xy3;
                    moveOnResize=true;
                    placed=true;
                end
            end
        end
    end

    function placed=tryPlacingOnBottom()
        placed=false;


        xy1=BL;
        xy2=xy1+WidgetSize;
        xy1ScreenIndex=getScreenIndexForPoint(xy1);

        if(xy1ScreenIndex>0)

            if(xy1ScreenIndex==getScreenIndexForPoint(xy2))
                position=xy1;
                placed=true;
            else



                currentScreen=screenInfo(xy1ScreenIndex,:);
                xy3=[min(currentScreen(1)+currentScreen(3)-1,xy1(1)+WidgetWidth)-WidgetWidth,xy1(2)];
                xy4=xy3+WidgetSize;
                xy3ScreenIndex=getScreenIndexForPoint(xy3);

                if(xy3ScreenIndex>0&&xy3ScreenIndex==getScreenIndexForPoint(xy4))
                    position=xy3;
                    placed=true;
                end
            end
        end
    end

    function placed=tryPlacingOnLeft()
        placed=false;


        xy1=[TL(1)-WidgetWidth,TL(2)];
        xy2=xy1+WidgetSize;
        xy1ScreenIndex=getScreenIndexForPoint(xy1);

        if(xy1ScreenIndex>0)

            if(xy1ScreenIndex==getScreenIndexForPoint(xy2))
                position=xy1;
                placed=true;
            else



                currentScreen=screenInfo(xy1ScreenIndex,:);
                xy3=[xy1(1),min(currentScreen(2)+currentScreen(4)-1,xy1(2)+WidgetHeight)-WidgetHeight];
                xy4=xy3+WidgetSize;
                xy3ScreenIndex=getScreenIndexForPoint(xy3);

                if(xy3ScreenIndex>0&&xy3ScreenIndex==getScreenIndexForPoint(xy4))
                    position=xy3;
                    moveOnResize=true;
                    placed=true;
                end
            end
        end
    end

    function placed=tryPlacingOnRight()
        placed=false;


        xy1=TR;
        xy2=TR+WidgetSize;
        xy1ScreenIndex=getScreenIndexForPoint(xy1);

        if(xy1ScreenIndex>0)

            if(xy1ScreenIndex==getScreenIndexForPoint(xy2))
                position=xy1;
                placed=true;
            else



                currentScreen=screenInfo(xy1ScreenIndex,:);
                xy3=[xy1(1),min(currentScreen(2)+currentScreen(4)-1,xy1(2)+WidgetHeight)-WidgetHeight];
                xy4=xy3+WidgetSize;
                xy3ScreenIndex=getScreenIndexForPoint(xy3);

                if(xy3ScreenIndex>0&&xy3ScreenIndex==getScreenIndexForPoint(xy4))
                    position=xy3;
                    moveOnResize=true;
                    placed=true;
                end
            end
        end
    end

    function id=getScreenIndexForPoint(xy)
        id=0;

        for idx=1:size(screenInfo,1)
            if(screenContainsPoint(screenInfo(idx,:),xy))
                id=idx;
                break;
            end
        end
    end

    function out=screenContainsPoint(currentScreen,point)
        screenStartPos=currentScreen(1:2);
        screenWidth=currentScreen(3);
        screenHeight=currentScreen(4);
        out=le(screenStartPos(1),point(1))&&lt(point(1),screenStartPos(1)+screenWidth)&&le(screenStartPos(2),point(2))&&lt(point(2),screenStartPos(2)+screenHeight);
    end
end