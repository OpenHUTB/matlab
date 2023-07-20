function compList=getChoices(this)








    compList=systemcomposer.arch.Component.empty(1,0);
    subsys=find_system(this.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,...
    'BlockType','SubSystem');
    mdlrefs=find_system(this.SimulinkHandle,'MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,...
    'BlockType','ModelReference');
    choices=[subsys(:);mdlrefs(:)];
    for i=1:numel(choices)
        if~isequal(choices(i),this.SimulinkHandle)
            cImpl=systemcomposer.utils.getArchitecturePeer(choices(i));
            compList(end+1)=this.getComponentWrapper(cImpl);
        end
    end
end