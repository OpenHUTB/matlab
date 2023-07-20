function addObsPortEntityMapping(obj,obsEntityInfo,obsEntitySplitSpec)





    obsEntitySplitFullName=arrayfun(@(x)extractAfter(getfullname(x),'/'),...
    obsEntitySplitSpec,'UniformOutput',false);


    repBlkFullName=[get_param(obj.MdlInfo.ModelH,'Name'),'/'...
    ,char(join(obsEntitySplitFullName,'/'))];


    if(obj.ObsPortEntityMappingInfo.isKey(repBlkFullName))



        obsEntityAndPortList=obj.ObsPortEntityMappingInfo(repBlkFullName);
        obsEntityAndPortList(end+1)=obsEntityInfo;
        obj.ObsPortEntityMappingInfo(repBlkFullName)=obsEntityAndPortList;
    else
        obj.ObsPortEntityMappingInfo(repBlkFullName)=obsEntityInfo;
    end

end
