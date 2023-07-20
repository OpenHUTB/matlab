


function[ResultStatus,constResultData,wasChecked,prerequisiteStatusArray,prerequisitesData]=checkBlockConstraint(block,system,constraint)

    prerequisiteStatus=true;
    prerequisitesChecked=true;
    preResultData=[];
    prerequisitesData={};

    dependentConstrs=constraint.getPreRequisiteConstraintObjects;
    prerequisiteStatusArray=false(1,numel(dependentConstrs));
    for n=1:length(dependentConstrs)
        dependentConstr=dependentConstrs(n);
        [tempStatus,preRequisiteData,tempWasChecked,~,prerequisitesData]=Advisor.authoring.internal.checkBlockConstraint(block,system,dependentConstr);

        if~tempStatus&&~isempty(preRequisiteData)
            prerequisitesData{end+1}.ID=dependentConstr.ID;
            prerequisitesData{end}.Data=preRequisiteData;
        end


        preResultData=[preResultData,preRequisiteData];%#ok<AGROW>


        prerequisitesChecked=prerequisitesChecked&&tempWasChecked;
        prerequisiteStatusArray(n)=tempStatus;

        prerequisiteStatus=tempStatus&&prerequisiteStatus;
    end






    if(prerequisitesChecked==true)&&(prerequisiteStatus==true)

        wasChecked=true;
        if isa(constraint,'Advisor.authoring.BlockParameterConstraint')
            [ResultStatus,constResultData]=checkBlockParamConstraint(constraint,block);
        elseif isa(constraint,'Advisor.authoring.internal.ModelParameterConstraint')

            [ResultStatus,constResultData]=checkModelParamConstraint(constraint,system);




        elseif isa(constraint,'Advisor.authoring.BlockTypeConstraint')
            [ResultStatus,constResultData]=checkBlockTypeConstraint(constraint,block);
        end

    elseif(prerequisitesChecked==false)&&(prerequisiteStatus==true)




        ResultStatus=true;
        constResultData=[];
        wasChecked=true;
    elseif(prerequisitesChecked==true)&&(prerequisiteStatus==false)
        ResultStatus=false;
        constResultData=[];
        wasChecked=true;
    else
        ResultStatus=true;
        constResultData=[];
        wasChecked=false;
    end
end

function[status,resultData]=checkBlockParamConstraint(constraint,block)
    resultData={};

    constraint.CurrentValue=get_param(block,constraint.ParameterName);
    status=constraint.check();

    if~status


        resultData{end+1}=constraint.CurrentValue;
    end
end

function[status,resultData]=checkModelParamConstraint(constraint,system)
    resultData={};
    try


        tempValue=get_param(system,constraint.ParameterName);
        constraint.setCurrentValue(tempValue);

        status=constraint.check();
    catch err
        DAStudio.error('Advisor:engine:CCUnableReadParameter',constraint.ParameterName);
    end
end

function[status,resultData]=checkBlockTypeConstraint(constraint,block)
    resultData={};

    blockType=get_param(block,'BlockType');
    maskType=get_param(block,'MaskType');

    constraint.setCurrentBlockType(blockType,maskType);
    status=constraint.check();
end
