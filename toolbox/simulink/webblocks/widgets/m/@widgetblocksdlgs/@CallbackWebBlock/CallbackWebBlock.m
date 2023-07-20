function this=CallbackWebBlock(h)
    this=widgetblocksdlgs.CallbackWebBlock(h);
    this.editingFcn=0;
    this.emptyPressFcn=isempty(this.get_param('PressFcn'));