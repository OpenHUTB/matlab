function allCaps=bcstExtractBlockCaps(model)




    modelName=get_param(model,'Name');
    modelPath=modelName;
    top=bdroot(model);
    parent=get_param(model,'Parent');
    if~isempty(parent)
        modelPath=[parent,'/',modelPath];
    end


    if bdIsLibrary(top)


        allBlks=find_system(top,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','block');
        allIdx=~cellfun('isempty',...
        regexp(allBlks,[modelPath,'/.*'],'start'));
        allBlks=allBlks(allIdx);

        if strcmp(model,'simulink')

            allIdx=cellfun('isempty',...
            regexp(allBlks,'(Commonly\sUsed\sBlocks|Examples|Quick\sInsert)','start'));
            allBlks=allBlks(allIdx);
        end
    else


        allBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','block');
    end

    if isempty(allBlks)
        allCaps=[];
        return;
    end


    isBad=isSubLibOrLaunchPad(allBlks);

    allBlks(isBad)=[];

    allBlks=sort(allBlks);

    cellCaps=get_param(allBlks,'Capabilities');
    allCaps=[cellCaps{:}];


end

function result=isSubLibOrLaunchPad(blocks)

    result=strcmp(get_param(blocks,'BlockType'),'SubSystem')&...
    strcmp(get_param(blocks,'Mask'),'on');

    for bx=1:length(result)
        if result(bx)
            blk=blocks{bx};
            result(bx)=isempty(get_param(blk,'MaskType'))||...
            (isempty(get_param(blk,'Blocks'))&&...
            ~isempty(get_param(blk,'OpenFcn')));
        end
    end

end


