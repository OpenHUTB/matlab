function[blks,found]=getLogicBlockUseNonBooleanOutput(model,mdladvObj)











    tmpBlocks=[];

    LogicBlks={'Logic',...
    'RelationalOperator',...
    'Interval Test',...
    'Interval Test Dynamic',...
    'Compare To Constant',...
    'Compare To Zero',...
    'Detect Change',...
    'Detect Increase',...
    'Detect Decrease',...
    'Detect Rise Positive',...
    'Detect Rise Nonnegative',...
    'Detect Fall Negative',...
    'Detect Fall Nonpositive'};



    found=false;
    for i=1:length(LogicBlks)


        if(i<=2)
            list=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','BlockType',LogicBlks{i});
        else
            list=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType',LogicBlks{i});
        end
        if~isempty(list)
            found=true;
            for j=1:length(list)
                blk=list(j);
                blkParameter=fieldnames(get_param(blk,'ObjectParameters'));
                if any(strcmp('OutDataTypeStr',blkParameter))
                    logicDT=get_param(blk,'OutDataTypeStr');
                    logicDT=Advisor.Utils.Simulink.outDataTypeStr2baseType(model,logicDT);
                    if~strcmp(logicDT,'boolean')
                        tmpBlocks{end+1}=blk;%#ok<AGROW>
                    end
                end
            end
        end
    end


    tmpBlocks=mdladvObj.filterResultWithExclusion(tmpBlocks);

    blks=tmpBlocks;

