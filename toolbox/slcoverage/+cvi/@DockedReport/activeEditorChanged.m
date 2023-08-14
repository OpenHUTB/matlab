function activeEditorChanged(this)





    if~this.isVisible
        return
    end

    this.refreshContent();

end