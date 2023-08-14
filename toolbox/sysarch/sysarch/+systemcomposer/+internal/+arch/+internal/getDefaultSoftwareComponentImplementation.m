function implementAs=getDefaultSoftwareComponentImplementation(blockH)





    swComp=systemcomposer.utils.getArchitecturePeer(blockH);
    swTrait=swComp.getArchitecture().getTrait(...
    systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);

    if~isempty(swTrait)
        componentFuncs=swTrait.getFunctionsOfType(...
        systemcomposer.architecture.model.swarch.FunctionType.OSFunction);
    else
        componentFuncs=[];
    end

    csInports=find_system(blockH,'BlockType','Inport','IsClientServer','on');
    csOutports=find_system(blockH,'BlockType','Outport','IsClientServer','on');

    if isempty(componentFuncs)&&isempty(csInports)&&isempty(csOutports)
        implementAs=systemcomposer.internal.arch.internal.ComponentImplementation.RateBased;
    else
        implementAs=systemcomposer.internal.arch.internal.ComponentImplementation.ExportFunction;
    end
end