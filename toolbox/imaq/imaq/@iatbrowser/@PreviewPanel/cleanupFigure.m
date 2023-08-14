function cleanupFigure(this)






    try
        setappdata(this.fig,'IgnoreCloseAll',2);
        close(this.fig);
        this.fig=[];
        this.destructor=[];
    catch %#ok<CTCH>
    end

end