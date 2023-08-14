function createContexts(this)






    paramContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
    paramContext.Tag=this.ParameterContext_tag;
    paramContext.PanelTags={this.ParameterPropsFigPanel_tag,this.ParameterControlPropsFigPanel_tag,this.ParameterOptionPropsFigPanel_tag};

    signalContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
    signalContext.Tag=this.SignalContext_tag;
    signalContext.PanelTags={this.SignalPropsFigPanel_tag,this.SignalControlPropsFigPanel_tag,this.SignalOptionPropsFigPanel_tag};

    signalWithLineContext=matlab.ui.container.internal.appcontainer.ContextDefinition();
    signalWithLineContext.Tag=this.SignalWithLineContext_tag;
    signalWithLineContext.PanelTags={this.SignalPropsFigPanel_tag,this.SignalControlPropsFigPanel_tag,this.SignalOptionPropsFigPanel_tag,this.SignalLinePropsFigPanel_tag};

    this.App.Contexts={paramContext,signalContext,signalWithLineContext};
end