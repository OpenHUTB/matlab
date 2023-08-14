function setVisible(this,vis)





    assert(islogical(vis),'argument should be of class logical');

    if vis
        set(this.fig,'Visible','on');
    else
        set(this.fig,'Visible','off');
    end

end