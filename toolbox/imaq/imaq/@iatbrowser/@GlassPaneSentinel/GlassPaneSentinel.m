function this=GlassPaneSentinel

    this=iatbrowser.GlassPaneSentinel;

    this.listener=handle.listener(this,'ObjectBeingDestroyed',@cleanup);

    function cleanup(obj,event)%#ok<INUSD,INUSD>
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(false);
    end
end

