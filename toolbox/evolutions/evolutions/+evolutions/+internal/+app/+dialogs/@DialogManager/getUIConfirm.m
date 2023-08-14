function output=getUIConfirm(h,displayMessage,varargin)




    title=getString(message('evolutions:ui:ConfirmAction'));

    if~h.ParentAppFigure.Visible

        h.ParentAppFigure.Visible='on';
    end

    output=uiconfirm(h.ParentAppFigure,displayMessage,title,varargin{:});
end


