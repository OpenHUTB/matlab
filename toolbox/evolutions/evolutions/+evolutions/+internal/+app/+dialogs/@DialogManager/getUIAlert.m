function getUIAlert(h,message,title,varargin)




    if~h.ParentAppFigure.Visible

        h.ParentAppFigure.Visible='on';
    end

    uialert(h.ParentAppFigure,message,title,varargin{:});
end

