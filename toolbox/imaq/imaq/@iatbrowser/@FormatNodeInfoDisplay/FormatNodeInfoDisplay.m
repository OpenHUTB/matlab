function this=FormatNodeInfoDisplay(node)











    if~isa(node,'iatbrowser.FormatNode')
        error(message('imaq:imaqtool:invalidNode','FormatNode'));
    end

    this=iatbrowser.FormatNodeInfoDisplay;
    initialize(this,node);
