function jmaab_jc_0643




    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0643');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0643_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0643';
    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0643',@hCheckAlgo),'PostCompile','DetailStyle');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0643_tip');
    rec.setLicense({styleguide_license});
    rec.Value=false;

    rec.SupportExclusion=true;
    rec.SupportLibrary=false;
    rec.SupportHighlighting=true;

    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end

function FailingObjs=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;



    AllBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',inputParams{1}.Value,'LookUnderMasks',inputParams{2}.Value);
    AllBlocks=mdladvObj.filterResultWithExclusion(AllBlocks);


    flags=false(1,length(AllBlocks));
    for i=1:length(AllBlocks)
        obj=get_param(AllBlocks{i},'Object');
        if isprop(obj,'OutDataTypeStr')
            outDataTypeStr=obj.OutDataTypeStr;
            if startsWith(outDataTypeStr,'fixdt')
                try
                    typObj=eval(outDataTypeStr);
                    if typObj.Bias~=0
                        flags(i)=true;
                    end
                catch
                    flags(i)=false;
                end


            elseif~isempty(obj.CompiledPortDataTypes)&&~isempty(obj.CompiledPortDataTypes.Outport)
                outDataTypeStr=obj.CompiledPortDataTypes.Outport{1};
                if startsWith(outDataTypeStr,'sfix')||startsWith(outDataTypeStr,'ufix')



                    startIndex=regexp(outDataTypeStr,'B\d+');
                    if isempty(startIndex)
                        continue;
                    end
                    if~iscell(startIndex)
                        startIndex={startIndex};
                    end

                    startIndex=startIndex{1}+1;
                    tempIndex=startIndex;
                    while tempIndex<=length(outDataTypeStr)
                        if outDataTypeStr(tempIndex)<'0'||outDataTypeStr(tempIndex)>'9'
                            break;
                        end
                        tempIndex=tempIndex+1;
                    end
                    tempIndex=min(tempIndex,length(outDataTypeStr));

                    numStr=extractBetween(outDataTypeStr,startIndex,tempIndex);
                    bias=str2double(numStr{1});
                    if bias~=0
                        flags(i)=true;
                    end
                end
            end
        end
    end

    FailingObjs=AllBlocks(flags);
end








