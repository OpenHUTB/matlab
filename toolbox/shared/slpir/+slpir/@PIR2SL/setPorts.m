
function setPorts(this,blockNameWithFullPath,hRef,hC)
    vc=hC.getPropertyValueString('ActiveVariant');
    if isempty(vc)
        return;
    end


    delete_block([blockNameWithFullPath,'/Variant_In1']);
    delete_block([blockNameWithFullPath,'/Variant_Out1']);

    vComps=hRef.Components;
    numComps=length(vComps);

    cmpiRefName=[blockNameWithFullPath,'/',vComps(1).Name];
    try
        set_param(cmpiRefName,'VariantControl',vc);
        if numComps==2
            delete_block([blockNameWithFullPath,'/',hC.Name]);
            cmpiRefName=[blockNameWithFullPath,'/',vComps(2).Name];
            set_param(cmpiRefName,'VariantControl','(default)');

            t1cmpRefName=[blockNameWithFullPath,'/',vComps(1).Name];
            set_param(t1cmpRefName,'TreatAsAtomicUnit','on');


            set_param(cmpiRefName,'TreatAsAtomicUnit','on');
        end
    catch
        disp('setPorts in variant subsystem');
    end
end
