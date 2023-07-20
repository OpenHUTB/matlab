function checkVariantSubsystems(rootId)




    topSlsf=cv('get',rootId','.topSlsf');
    allIds=cv('DecendentsOf',topSlsf);
    allIds=cv('find',allIds,'.origin',1);

    for idx=1:numel(allIds)
        cid=allIds(idx);
        ch=cv('get',cid,'.handle');
        ct=Simulink.SubsystemType(ch);
        if ct.isSubsystem
            pid=cv('get',cid,'.treeNode.parent');
            if cv('get',pid,'.origin')==1
                ph=cv('get',pid,'.handle');
                pt=Simulink.SubsystemType(ph);
                if pt.isVariantSubsystem
                    blockPath=getfullname(get_param(ph,'ActiveVariantBlock'));
                    variantPath=getfullname(ph);
                    rootVariantId=cvi.RootVariant.addRootVariant(rootId,blockPath,variantPath);
                    if~isempty(rootVariantId)
                        cvi.RootVariant.setRootVariantState(rootId,rootVariantId,1);
                    end
                end
            end
        end
    end

end


