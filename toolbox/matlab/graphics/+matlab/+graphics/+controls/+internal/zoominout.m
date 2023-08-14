function zoominout(fig,buttonValue,zoomButtonType)








    if strcmpi(buttonValue,'on')
        if strcmpi(zoomButtonType,matlab.graphics.controls.internal.ToolbarValidator.zoomin)
            buttonState='inmode';
        else
            buttonState='outmode';
        end
    else

        buttonState='off';
    end

    zoom(fig,buttonState);
end