function hisl_0023
    rec=getNewCheckObject('mathworks.hism.hisl_0023',false,@hCheckAlgo,'None');

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)
    variantActvTime='';
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    variantBlockInstances=slprivate('slFindVariantBlocks',system);
    variantBlockInstances=mdlAdvObj.filterResultWithExclusion(variantBlockInstances);

    flags=false(1,numel(variantBlockInstances));
    for i=1:numel(variantBlockInstances)
        vBlock=variantBlockInstances{i};
        if isprop(get_param(vBlock,'handle'),'VariantActivationTime')
            variantActvTime=get_param(vBlock,'VariantActivationTime');
        end
        if strcmp(variantActvTime,'code compile')
            flags(i)=true;
        end
    end

    violations=variantBlockInstances(flags);

end
