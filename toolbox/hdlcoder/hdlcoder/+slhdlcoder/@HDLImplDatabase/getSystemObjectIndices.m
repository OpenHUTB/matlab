function sysObjIdxes=getSystemObjectIndices(~,blocks)



    sysObjIdxes=false(numel(blocks),1);
    for ii=1:numel(blocks)
        name=blocks{ii};
        if any(name=='.')&&...
            matlab.system.internal.isMATLABAuthoredSystemObjectName(name)
            sysObjIdxes(ii)=true;
        end
    end

end
