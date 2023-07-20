function spec=ddg(dialogHandle,widgetTag)
    widgetPos=dialogHandle.getWidgetPosition(widgetTag);
    topLeft=widgetPos(1:2);
    bottomRight=widgetPos(1:2)+widgetPos(3:4);
    spec=Simulink.output.PositionSpecification;
    spec.setPreferredSide(Simulink.output.utils.PreferredSide.BOTTOM);
    spec.setTopLeftAndBottomRightCorners(topLeft,bottomRight);
end