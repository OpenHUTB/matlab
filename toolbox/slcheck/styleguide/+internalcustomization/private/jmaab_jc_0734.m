function jmaab_jc_0734

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0734');
    rec.Title=DAStudio.message('ModelAdvisor:jmaab:jc_0734_title');
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0734';
    rec.setCallbackFcn(@CheckCallBackFcn,'none','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:jmaab:jc_0734_tip');
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.Value=true;
    rec.SupportHighlighting=true;
    rec.SupportLibrary=true;
    rec.SupportExclusion=true;
    rec.setInputParametersLayoutGrid([1,4]);

    inputParamList{1}=Advisor.Utils...
    .createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils...
    .createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='graphical';

    rec.setInputParameters(inputParamList);
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function ElementResults=CheckCallBackFcn(system)
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    resultData=checkAlgo(system);
    [bResultStatus,ElementResults]=Advisor.Utils.getTwoColumnReport...
    ('ModelAdvisor:jmaab:jc_0734',resultData.failedCharts);
    if resultData.noChartsFound
        ElementResults.setSubResultStatusText(DAStudio.message...
        ('ModelAdvisor:jmaab:jc_0734_no_stateflow_chart'));
    end
    mdlAdvObj.setCheckResultStatus(bResultStatus);
end


function[resultData]=checkAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    sfStates=Advisor.Utils.Stateflow...
    .sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,...
    {'-isa','Stateflow.State'});
    if~isempty(sfStates)
        sfStates=mdladvObj.filterResultWithExclusion(sfStates);
        failedStatetElements=[];
        for c1=1:length(sfStates)
            fData=checkForActionTypes(sfStates{c1});
            if~isempty(fData)
                failedStatetElements=[failedStatetElements;...
                fData];
            end
        end
        resultData.noChartsFound=false;
        resultData.failedCharts=failedStatetElements;

    else
        resultData.noChartsFound=true;
        resultData.failedCharts=[];
    end
end


function failedData=checkForActionTypes(sfState)












    failedData=[];
    sfASyntax=sfState.LabelString;

    labelstr_split=regexp(sfASyntax,'\n','split');



    expressionComment='^%.*|(\/\*)+.*(\*\/)+|(\/\/)+.*';
    comment_filtered=cellfun(@(x)regexprep(x,expressionComment,''),labelstr_split,'UniformOutput',false);
    comment_filtered=comment_filtered(cellfun(@(x)~isempty(x),comment_filtered));
    comment_filtered=strjoin(comment_filtered,'\n');



    sfASyntax=regexprep(comment_filtered,'(entry|during|exit)[a-zA-Z]+','');
    [sfATypes,startIndex,stopIndex]=regexp(sfASyntax,'((en|ex|du)[a-zA-Z, ]*:)','tokens');
    sfATMapped=sfATMapper(sfATypes);
    sfATypeUnique=unique(sfATMapped,'stable');
    countOfActionTypes=arrayfun(@(x)sum(ismember(sfATMapped,x)),sfATypeUnique,'UniformOutput',false);
    repeatedIndex=find([countOfActionTypes{:}]>1);
    if~isempty(repeatedIndex)





        repeatedLIndex=ismember(sfATMapped,sfATypeUnique(repeatedIndex));

        startI=startIndex(repeatedLIndex);
        stopI=stopIndex(repeatedLIndex);

        currentSFLength=length(sfASyntax);

        for c2=1:length(startI)




            startI(c2)=startI(c2)+(length(sfASyntax)-currentSFLength);
            stopI(c2)=stopI(c2)+(length(sfASyntax)-currentSFLength);

            sfASyntax=Advisor.Utils.Naming.formatFlaggedName(sfASyntax,2,[startI(c2),stopI(c2)],'');

        end

        failedData={Advisor.Utils.Simulink.getObjHyperLink(sfState),getMAText(sfASyntax)};
    end
end



function sfATMap=sfATMapper(sfAT)













    sfATMap=zeros(1,length(sfAT));
    for c1=1:length(sfAT)
        sfATNew=0;
        if contains(sfAT{c1},'en')||contains(sfAT{c1},'entry')
            sfATNew=sfATNew+1;
        end
        if contains(sfAT{c1},'du')||contains(sfAT{c1},'during')
            sfATNew=sfATNew+10;
        end
        if contains(sfAT{c1},'ex')||contains(sfAT{c1},'exit')
            sfATNew=sfATNew+100;
        end
        sfATMap(c1)=sfATNew;
    end
end

function MAText=getMAText(textData)
    MAText=ModelAdvisor.Text(textData);
    MAText.RetainReturn=true;
    MAText.RetainSpaceReturn=true;
end

