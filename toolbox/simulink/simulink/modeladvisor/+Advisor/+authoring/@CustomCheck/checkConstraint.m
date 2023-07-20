



function[ResultStatus,constrResultData,wasChecked,isInformational]=checkConstraint(this,system,constraintID)

    constrResultData=[];


    constraint=this.Constraints(constraintID);
    isInformational=constraint.IsInformational;


    prerequisiteStatus=true;
    allPrerequisitesAreInformational=true;
    prerequisitesChecked=true;


    dependentConstrIDs=constraint.getPreRequisiteConstraintIDs;

    for n=1:length(dependentConstrIDs)
        [tempStatus,preRequisiteData,tempWasChecked,tempIsInformational]=this.checkConstraint(system,dependentConstrIDs{n});


        constrResultData=[constrResultData,preRequisiteData];%#ok<AGROW>


        prerequisitesChecked=prerequisitesChecked&&tempWasChecked;


        prerequisiteStatus=tempStatus&&prerequisiteStatus;


        if~tempIsInformational
            allPrerequisitesAreInformational=false;
        end
    end






    if(prerequisitesChecked==true)&&(prerequisiteStatus==true)

        wasChecked=true;
        if~constraint.WasChecked
            [ResultStatus,constResultData]=constraint.check(system);


            constrResultData=[constrResultData,constResultData];


            if~ResultStatus&&constraint.HasFix&&~constraint.IsInformational
                this.EnableFixIt=true;
            end
        else
            ResultStatus=constraint.Status;
            constrResultData=[];
        end
    elseif(prerequisitesChecked==false)&&(prerequisiteStatus==true)




        ResultStatus=true;
    else




        if allPrerequisitesAreInformational
            ResultStatus=true;
        else
            ResultStatus=false;
        end
        wasChecked=false;
    end
    constraint.ResultStatus=ResultStatus;
end
