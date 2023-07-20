function highlightStreaming(this)













    if~isempty(this.BindModeInstrument)&&~isempty(this.BindModeInstrument.signals)
        bdH=get_param(this.BindModeModelName,'Handle');
        SLStudio.HighlightSignal.removeHighlighting(bdH);

        for i=1:length(this.BindModeInstrument.signals)
            slrealtime.internal.highlightSignal(...
            this.BindModeInstrument.signals(i).blockpath,...
            this.BindModeInstrument.signals(i).portindex,...
            false);
        end
    end
end
