function setPanMode(fig,buttonValue)







    if strcmpi(buttonValue,'on')
        buttonState='onkeepstyle';
    else

        buttonState='off';
    end

    pan(fig,buttonState);
end