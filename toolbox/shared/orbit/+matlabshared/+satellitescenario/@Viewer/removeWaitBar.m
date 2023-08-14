function removeWaitBar(viewer)






    uiFigure=viewer.UIFigure;


    uiWaitBar=viewer.UIWaitBar;


    if isa(uiFigure,'matlab.ui.Figure')&&isvalid(uiFigure)&&...
        isa(uiWaitBar,'matlab.ui.dialog.ProgressDialog')
        delete(uiWaitBar);
    end
end

