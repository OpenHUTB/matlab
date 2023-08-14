function this=RootNodeInfoDisplay(node)











    if~isa(node,'iatbrowser.RootNode')
        error(message('imaq:imaqtool:invalidNode','RootNode'));
    end

    this=iatbrowser.RootNodeInfoDisplay;
    initialize(this,node);
