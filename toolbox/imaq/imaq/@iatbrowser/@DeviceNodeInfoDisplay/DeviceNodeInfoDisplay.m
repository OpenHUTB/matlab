function this=DeviceNodeInfoDisplay(node)

    if~isa(node,'iatbrowser.DeviceNode')
        error(message('imaq:imaqtool:invalidNode','DeviceNode'));
    end
    this=iatbrowser.DeviceNodeInfoDisplay;
    initialize(this,node);
