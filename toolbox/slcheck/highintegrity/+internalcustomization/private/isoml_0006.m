




function isoml_0006
    rec=getNewCheckObject('mathworks.hism.isoml_0006',false,@hCheckAlgo,'None');

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';

    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParametersLayoutGrid([2,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(systemName)
    violations=[];
    modelName=bdroot(systemName);
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(modelName);
    followLinks=mdlAdvObj.getInputParameterByName('Follow links');
    lookUnderMasks=mdlAdvObj.getInputParameterByName('Look under masks');

    sfBlockTypes={'MATLAB Function','Chart'};
    blocks=cell(0,1);
    for i=1:numel(sfBlockTypes)
        thisSfBlockType=sfBlockTypes{i};


        list=find_system(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks',followLinks.value,...
        'LookUnderMasks',lookUnderMasks.value,...
        'Type','Block',...
        'SFBlockType',thisSfBlockType);
        blocks=[blocks;list];%#ok<AGROW>
    end

    for i=1:numel(blocks)
        hndlEmChart=find(slroot,'-isa','Stateflow.EMChart','Path',blocks{i});
        functionBody=hndlEmChart.Script;
        if~contains(functionBody,'%#codegen')
            violations=[violations;hndlEmChart.Path];%#ok<AGROW>
        end
    end
end
