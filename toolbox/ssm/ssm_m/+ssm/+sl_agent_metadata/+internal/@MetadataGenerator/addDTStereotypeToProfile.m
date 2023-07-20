function addDTStereotypeToProfile(profile,dtMap)












    fids=fieldnames(dtMap);

    for idx=1:length(fids)
        blkType=fids{idx};
        portBase=profile.addStereotype(blkType,'AppliesTo','Port');
        properties=unique(struct2cell(dtMap.(blkType)));
        for idy=1:length(properties)
            portBase.addProperty(properties{idy},'Type','string','DefaultValue','');
        end
    end

end
