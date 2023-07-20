function destroy(this,destroyJava)












    if destroyJava
        try
            javaMethodEDT('destroy',java(this.prevPanelButtonPanel));
        catch

        end
    end

    this.prevPanelButtonPanel=[];
    this.statLabel=[];
    this.timeLabel=[];
    this.frameRateLabel=[];
    this.data=[];

    this.cleanupFigure();

    delete(this);