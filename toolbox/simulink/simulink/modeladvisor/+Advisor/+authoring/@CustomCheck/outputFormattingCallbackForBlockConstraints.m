function ft=outputFormattingCallbackForBlockConstraints(CheckResultStatus,CustomCheckObj,resultData)




    ft={};


    IdConstraintThatAreViolated=resultData.keys;


    CompositeConstraints=CustomCheckObj.CompositeConstraints;
    if numel(CompositeConstraints)>1
        masterFt=ModelAdvisor.FormatTemplate('TableTemplate');
        masterFt.setCheckText(DAStudio.message('Advisor:engine:CompositeConstraintSummary'));
        masterFt.setSubBar(true);
        ft{end+1}=masterFt;
    end

    for i=1:numel(CompositeConstraints)
        compositeFt=ModelAdvisor.FormatTemplate('ListTemplate');
        compositeFt.setSubTitle([DAStudio.message('Advisor:engine:CompositeConstraint'),' ',num2str(i)]);
        switch CompositeConstraints{i}.getCompositeOperator
        case 'and'
            compositeFt.setInformation(DAStudio.message('Advisor:engine:CompositeConstraintPassIfAllPass'));
        case 'or'
            compositeFt.setInformation(DAStudio.message('Advisor:engine:CompositeConstraintPassIfAnyPass'));
        end
        compositeFt.setSubBar(false);
        ft{end+1}=compositeFt;%#ok<AGROW>
        AllConstraints=CompositeConstraints{i}.getConstraintObjects;
        PrerequisiteConstraintsID={};
        for idx=1:numel(AllConstraints)
            PrerequisiteConstraintsID=[PrerequisiteConstraintsID,AllConstraints{idx}.getPreRequisiteConstraintObjects().ID];%#ok<AGROW>
        end
        subConstraintCount=1;
        for idx=1:numel(AllConstraints)
            if~ismember(AllConstraints{idx}.ID,PrerequisiteConstraintsID)
                if ismember(AllConstraints{idx}.ID,IdConstraintThatAreViolated)
                    currID=AllConstraints{idx}.ID;
                    dataForConstraintId=resultData(currID);
                    thisConstraint=CustomCheckObj.Constraints(currID);
                    [Description,recommendedAction,SupportedValuesColHead,SupportedValues]=getConstraintAndPrerequisiteSection(thisConstraint,resultData);
                    if isa(Description,'Advisor.Element')
                        Description(1).setContent([DAStudio.message('Advisor:engine:Constraint'),' ',num2str(subConstraintCount),': ',Description(1).Content]);
                    end
                    if(size(dataForConstraintId,2)>1)
                        locFt=ModelAdvisor.FormatTemplate('TableTemplate');
                        locFt.setCheckText(Description);
                        ColHeads={DAStudio.message('Advisor:engine:BlockPath'),DAStudio.message('Advisor:engine:CurrentValue'),SupportedValuesColHead};
                        locFt.setColTitles(ColHeads);
                        locFt.setRecAction(recommendedAction);

                        for y=1:size(dataForConstraintId,1)
                            row=[];
                            ThisRowPrerequisiteNotMet=false;
                            for z=1:size(dataForConstraintId,2)
                                row=[row,dataForConstraintId(y,z)];%#ok<AGROW>
                                if strcmp(dataForConstraintId{y,z},'Prerequisite not met')
                                    ThisRowPrerequisiteNotMet=true;
                                end
                            end
                            [numRows,~]=size(SupportedValues);
                            if numRows>1
                                row=[row,SupportedValues'];%#ok<AGROW>
                            else
                                row=[row,SupportedValues];%#ok<AGROW>
                            end
                            if~ThisRowPrerequisiteNotMet
                                locFt.addRow(row);
                            end
                        end
                    else
                        locFt=ModelAdvisor.FormatTemplate('ListTemplate');
                        locFt.setCheckText(Description);
                        locFt.setRecAction(recommendedAction);
                        locFt.ListObj=dataForConstraintId;
                    end
                    locFt.setSubResultStatus('Warn');
                else
                    locFt=ModelAdvisor.FormatTemplate('TableTemplate');
                    Description=getConstraintAndPrerequisiteSection(AllConstraints{idx},resultData);
                    if isa(Description,'Advisor.Element')
                        Description(1).setContent(['Constraint ',num2str(subConstraintCount),': ',Description(1).Content]);
                    end
                    locFt.setInformation(Description);
                    locFt.setSubResultStatus('Pass');
                end
                locFt.setSubBar(false);
                ft{end+1}=locFt;%#ok<AGROW>
                subConstraintCount=subConstraintCount+1;
            end
        end
        ft{end}.setSubBar(true);
    end
    ft{end}.setSubBar(false);














































































end

function[Description,recommendedAction,SupportedValuesColHead,SupportedValues]=getConstraintAndPrerequisiteSection(thisConstraint,resultData)
    [Description,recommendedAction,SupportedValuesColHead,SupportedValues]=getConstraintDescription(thisConstraint);
    PreReqObjs=thisConstraint.getPreRequisiteConstraintObjects();
    if~isempty(PreReqObjs)
        PreRequisiteList=Advisor.List;
        PreRequisiteList.setAttribute('style','list-style-type:none');
        PreRequisiteFailed=false;
        for i=1:numel(PreReqObjs)

            PreRequisiteDescription=getConstraintAndPrerequisiteSection(PreReqObjs(i),resultData);























            PreRequisiteDescription=Advisor.Text(PreRequisiteDescription);
            PreRequisiteDescription.setItalic(true);
            PreRequisiteList.addItem(PreRequisiteDescription);
            if~PreReqObjs(i).Status
                PreRequisiteFailed=true;
            end
        end
        if PreRequisiteFailed
            PrerequisiteTitle=Advisor.Text(DAStudio.message('Advisor:engine:AboveConstraintHasPrerequisitesFailed'));
        else
            PrerequisiteTitle=Advisor.Text(DAStudio.message('Advisor:engine:AboveConstraintHasPrerequisites'));
        end
        PrerequisiteTitle.setItalic(true);
        Description=[Description,Advisor.LineBreak,PrerequisiteTitle,PreRequisiteList];
    end
end

function[output,recommendedAction,colHead,values]=getConstraintDescription(ConstraintObj)
    switch class(ConstraintObj)
    case 'Advisor.authoring.PositiveBlockParameterConstraint'
        output=DAStudio.message('Advisor:engine:BlockParameterConstraintDescription',ConstraintObj.ParameterName,ConstraintObj.BlockType);
        values=ConstraintObj.SupportedParameterValues;
        switch ConstraintObj.ValueOperator
        case 'eq'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionEQ',ConstraintObj.SupportedParameterValues{:})];
        case 'lt'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionLT',ConstraintObj.SupportedParameterValues{:})];
        case 'gt'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionGT',ConstraintObj.SupportedParameterValues{:})];
        case 'le'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionLE',ConstraintObj.SupportedParameterValues{:})];
        case 'ge'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionGE',ConstraintObj.SupportedParameterValues{:})];
        case 'or'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionOR',emitValues(ConstraintObj.SupportedParameterValues))];
            values=emitValues(values);
        case 'range'
            values=['[',ConstraintObj.SupportedParameterValues{1},',',ConstraintObj.SupportedParameterValues{2},']'];
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionRANGE',ConstraintObj.SupportedParameterValues{:})];
        case 'regex'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionREGEX',ConstraintObj.SupportedParameterValues{:})];
        otherwise
            DAStudio.error('Advisor:engine:InvalidConstraintOperator');
        end
        output=Advisor.Text(output);
        colHead=DAStudio.message('Advisor:engine:SupportedValues');
        recommendedAction=DAStudio.message('Advisor:engine:BlockParameterConstraintRecAction');
    case 'Advisor.authoring.NegativeBlockParameterConstraint'
        output=DAStudio.message('Advisor:engine:BlockParameterConstraintDescription',ConstraintObj.ParameterName,ConstraintObj.BlockType);
        values=ConstraintObj.UnsupportedParameterValues;
        switch ConstraintObj.ValueOperator
        case 'eq'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionEQN',ConstraintObj.UnsupportedParameterValues{:})];
        case 'lt'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionLTN',ConstraintObj.UnsupportedParameterValues{:})];
        case 'gt'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionGTN',ConstraintObj.UnsupportedParameterValues{:})];
        case 'le'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionLEN',ConstraintObj.UnsupportedParameterValues{:})];
        case 'ge'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionGEN',ConstraintObj.UnsupportedParameterValues{:})];
        case 'or'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionORN',emitValues(ConstraintObj.UnsupportedParameterValues))];
            values=emitValues(values);
        case 'range'
            values=['[',ConstraintObj.SupportedParameterValues{1},',',ConstraintObj.SupportedParameterValues{2},']'];
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionRANGEN',ConstraintObj.SupportedParameterValues{:})];
        case 'regex'
            output=[output,' ',DAStudio.message('Advisor:engine:BlockParameterConstraintDescriptionREGEXN',ConstraintObj.UnsupportedParameterValues{:})];
        otherwise
            DAStudio.error('Advisor:engine:InvalidConstraintOperator');
        end
        colHead=DAStudio.message('Advisor:engine:UnsupportedValues');
        recommendedAction=DAStudio.message('Advisor:engine:BlockParameterConstraintRecAction');
    case 'Advisor.authoring.PositiveBlockTypeConstraint'
        output=Advisor.Text(DAStudio.message('Advisor:engine:PositiveBlockTypeConstraintDescription'));
        blktypeTable=Advisor.Table(numel(ConstraintObj.SupportedBlockTypes),2);
        blktypeTable.setColHeading(1,DAStudio.message('Advisor:engine:BlockType'));
        blktypeTable.setColHeading(2,DAStudio.message('Advisor:engine:MaskType'));
        for i=1:numel(ConstraintObj.SupportedBlockTypes)
            blktypeTable.setEntry(i,1,ConstraintObj.SupportedBlockTypes{i}.BlockType);
            blktypeTable.setEntry(i,2,ConstraintObj.SupportedBlockTypes{i}.MaskType);
        end
        output=[output,blktypeTable];
        colHead='';
        values={};
        recommendedAction=DAStudio.message('Advisor:engine:BlockTypeConstraintRecAction');
    case 'Advisor.authoring.NegativeBlockTypeConstraint'
        output=Advisor.Text(DAStudio.message('Advisor:engine:NegativeBlockTypeConstraintDescription'));
        blktypeTable=Advisor.Table(numel(ConstraintObj.UnsupportedBlockTypes),2);
        blktypeTable.setColHeading(1,DAStudio.message('Advisor:engine:BlockType'));
        blktypeTable.setColHeading(2,DAStudio.message('Advisor:engine:MaskType'));
        for i=1:numel(ConstraintObj.UnsupportedBlockTypes)
            blktypeTable.setEntry(i,1,ConstraintObj.UnsupportedBlockTypes{i}.BlockType);
            blktypeTable.setEntry(i,2,ConstraintObj.UnsupportedBlockTypes{i}.MaskType);
        end
        output=[output,blktypeTable];
        colHead='';
        values={};
        recommendedAction=DAStudio.message('Advisor:engine:BlockTypeConstraintRecAction');
    case 'Advisor.authoring.internal.PositiveModelParameterConstraint'

        paramValues=emitValues(ConstraintObj.SupportedParameterValues);
        output=DAStudio.message('Advisor:engine:PositiveModelParameterConstraintDescription',ConstraintObj.ParameterName,paramValues);
        output=Advisor.Text(output);
        colHead='';
        values={};
        recommendedAction='';
    case 'Advisor.authoring.internal.NegativeModelParameterConstraint'
        paramValues=emitValues(ConstraintObj.UnsupportedParameterValues);
        output=DAStudio.message('Advisor:engine:NegativeModelParameterConstraintDescription',ConstraintObj.ParameterName,paramValues);
        output=Advisor.Text(output);
        colHead='';
        values={};
        recommendedAction='';
    otherwise
        output=DAStudio.error('Advisor:engine:UnsupportedConstraint');
        colHead='';
        values={};
        recommendedAction='';
    end
end

function output=emitValues(input)
    output='';
    for i=1:length(input)
        newValue='';
        if iscell(input{i})
            for j=1:numel(input{i})
                newValue=[newValue,' ',input{i}{j}];%#ok<AGROW>
            end
        else
            if isstruct(input{i})
                newValue=evalc('disp(input{i})');
            else
                newValue=input{i};
            end
        end
        if isempty(output)
            output=newValue;
        else
            output=[output,' or ',newValue];%#ok<AGROW>
        end
    end
end


