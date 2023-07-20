


function ft=getModelParameterOutput(this,system)
    ft=ModelAdvisor.FormatTemplate('TableTemplate');


    if isempty(this.Description)
        dataFileLink=this.createLinkToDataFile();
        ft.setCheckText(DAStudio.message('Advisor:engine:CCOFModelParamCheckText',dataFileLink.emitHTML));
    else
        ft.setCheckText(this.Description);
    end


    if strcmp(this.CheckStatus,'Pass')
        if isempty(this.ResultDescriptionPass)
            ft.setSubResultStatusText(DAStudio.message('Advisor:engine:CCOFModelParamPass'));
        else
            ft.setSubResultStatusText(this.ResultDescriptionPass);
        end
    else
        if isempty(this.ResultDescriptionFail)
            ft.setSubResultStatusText(DAStudio.message('Advisor:engine:CCOFModelParamFail'));
        else
            ft.setSubResultStatusText(this.ResultDescriptionFail);
        end
    end


    ft.setSubResultStatus(this.CheckStatus);

    if~strcmp(this.CheckStatus,'Pass')

        if isempty(this.RecommendedActions)
            ft.setRecAction(ModelAdvisor.Text(DAStudio.message('Advisor:engine:CCOFModelParamRecAct')));
        else
            ft.setRecAction(ModelAdvisor.Text(this.RecommendedActions));
        end
    end


    colHeadings={DAStudio.message('Advisor:engine:Status'),...
    DAStudio.message('Advisor:engine:Parameter'),...
    DAStudio.message('Advisor:engine:CurrentValue'),...
    DAStudio.message('Advisor:engine:RecValues'),...
    DAStudio.message('Advisor:engine:UnrecValues'),...
    DAStudio.message('Advisor:engine:DependsOn')};

    constraintIDs=this.Constraints.keys;

    tableContent=cell(0,6);

    invertedLogic=false;
    for n=1:this.Constraints.length
        constraint=this.Constraints(constraintIDs{n});

        [row,tempHasInvertedLogic]=getConstraintInfo(this,constraint,system);


        if~isempty(row)
            tableContent(end+1,:)=row;%#ok<AGROW>
        end


        invertedLogic=invertedLogic||tempHasInvertedLogic;
    end


    for n=[6,5,4]
        if isempty([tableContent{:,n}])
            colHeadings(n)=[];
            tableContent(:,n)=[];
        end
    end

    ft.setColTitles(colHeadings);

    for n=1:size(tableContent,1)
        ft.addRow(tableContent(n,:));
    end


    if invertedLogic
        ft.RecAction=[ft.RecAction,ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(DAStudio.message('Advisor:engine:CCOFModelParamInvertedLogicFootnote'))];
    end


    ft.setSubBar(false);
end


function[info,hasInvertedLogic]=getConstraintInfo(this,constraint,system)
    hasInvertedLogic=false;


    if this.getConstraintOutputStatus(constraint)


        if~constraint.IsRootConstraint
            dependencyFlag='D - ';
        else
            dependencyFlag='';
        end

        info{1}=[dependencyFlag,this.getStatusString(constraint)];




        if constraint.HasInvertedLogic
            info{2}=[constraint.getHyperlinkToParameter(system),ModelAdvisor.Text('*')];
            hasInvertedLogic=true;
        else
            info{2}=constraint.getHyperlinkToParameter(system);
        end



        if constraint.WasChecked&&isempty(constraint.CheckingErrorMessage)
            info{3}=constraint.value2String(constraint.CurrentValue);
        elseif~isempty(constraint.CheckingErrorMessage)
            info{3}=constraint.CheckingErrorMessage;
        else
            info{3}=DAStudio.message('Advisor:engine:CCOFPreRequConstraintNotFullfilled');
        end


        if isa(constraint,'Advisor.authoring.PositiveModelParameterConstraint')||...
            isa(constraint,'Advisor.authoring.ERTSystemTargetFileParameterConstraint')
            vcell=constraint.getSupportedValues();

            for ii=1:length(vcell)
                vcell{ii}=constraint.value2String(vcell{ii});
            end
            info{4}=this.cell2String(vcell);
        else
            info{4}='';
        end


        if isa(constraint,'Advisor.authoring.NegativeModelParameterConstraint')
            vcell=constraint.getUnsupportedValues();

            for ii=1:length(vcell)
                vcell{ii}=constraint.value2String(vcell{ii});
            end
            info{5}=this.cell2String(vcell);
        else
            info{5}='';
        end


        info{6}=getDependentParameterNames(this,constraint.getPreRequisiteConstraintIDs);
    else
        info=[];
    end
end


function dependentParametersNameStr=getDependentParameterNames(this,ids)
    dependentParameters={};

    for n=1:length(ids)
        constraint=this.Constraints(ids{n});
        if~constraint.IsInformational
            dependentParameters{end+1}=this.Constraints(ids{n}).ParameterName;%#ok<AGROW>
        end
    end

    dependentParametersNameStr=this.cell2String(dependentParameters);
end