function[data,whichModelEntry,mdl]=getBlockData(this,block,mdl)








    if nargin<3
        mdl=[];
    end


    if isempty(mdl)
        mdl=get_param(pmsl_bdroot(block.Handle),'Object');
    end

    data=[];

    [blockList,whichModelEntry]=this.getModelBlockEntries(mdl);
    whichBlock=find([blockList.block]==block);
    howManyBlocks=length(whichBlock);

    switch howManyBlocks

    case 1

        data=this.modelInfo(whichModelEntry).blockList(whichBlock).data;

    case 0

        data=[];

    otherwise

        configData=RtmModelRegistry_config;
        pm_error(configData.Error.MultiplyRegisteredBlock_templ_msgid,pm_sanitize(block.Name));

    end




