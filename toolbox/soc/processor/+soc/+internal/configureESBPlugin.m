function configureESBPlugin(mdlName,varargin)



    if nargin>1
        validateattributes(varargin{1},{'char'},{'nonempty'});
        detach=~isequal(varargin{1},'attach');
    else
        detach=false;
    end
    h=Simulink.PluginMgr;
    if detach
        h.detach(mdlName,'ESBCompPluginID');
    else
        h.attach(mdlName,'ESBCompPluginID');
    end

end