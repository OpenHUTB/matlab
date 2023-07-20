function areTheSame=compareBlockToSnapshot(this,block);








    areTheSame=true;
    maskParam=this.blockGetParameterModes(block);

    if~isempty(maskParam)

        authoringModeParams={maskParam(strcmp(PARAM_AUTHORING,{maskParam.editingMode})).maskName};
        maskNames=block.MaskNames;
        authoringIdx=ismember(maskNames,authoringModeParams);


        maskValues=block.MaskValues;
        authoringParams=maskValues(authoringIdx);


        snapshot=this.getBlockSnapshot(block);
        authoringSnapshot=snapshot.values(authoringIdx);


        areTheSame=all(strcmp(authoringSnapshot,authoringParams));

    end



