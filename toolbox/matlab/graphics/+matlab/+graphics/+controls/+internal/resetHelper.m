function resetHelper(ax,isWeb)





    if numel(ax)>1
        for i=1:numel(ax)
            matlab.graphics.controls.internal.resetHelper(ax(i),isWeb)
        end
        return;
    end


    if isappdata(ax,'graphicsPlotyyPeer')


        ax=[ax,getappdata(ax,'graphicsPlotyyPeer')];
    end

    for i=1:numel(ax)
        resetplotview(ax(i),'ApplyStoredView');
        matlab.graphics.interaction.internal.setInteractiveDDUXData(ax,'homerestoreview','default');
        matlab.graphics.interaction.generateLiveCode(ax(i),...
        matlab.internal.editor.figure.ActionID.RESET_LIMITS);
    end

end

