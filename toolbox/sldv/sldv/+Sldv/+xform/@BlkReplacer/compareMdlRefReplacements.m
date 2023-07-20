function compareMdlRefReplacements(obj)




    busObjectList=...
    get_param(obj.MdlInfo.ModelH,'BackPropagatedBusObjects');
    for idx=1:length(obj.ReplacedMdlRefBlks)
        Sldv.xform.BlkReplacer.compareInOutPorts(obj.ReplacedMdlRefBlks{idx},busObjectList);
    end
end