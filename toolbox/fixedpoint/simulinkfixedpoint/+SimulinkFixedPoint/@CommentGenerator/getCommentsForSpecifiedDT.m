function comments=getCommentsForSpecifiedDT(this,DTConInfo)








    comments={};

    if~DTConInfo.isFixed

        stringID=[this.stringIDPrefix,'DT'];


        if DTConInfo.isAlias


            stringIDToAppend='AliasType';
        else
            containerType=DTConInfo.containerType;
            stringIDToAppend=char(containerType);
        end

        inheritanceType=DTConInfo.getInheritanceType;
        if(inheritanceType==SimulinkFixedPoint.AutoscalerInheritanceTypes.FROMSIMULINKSIGNALOBJECT)



            stringID=[stringID,char(inheritanceType)];
        else


            stringID=[stringID,stringIDToAppend];
        end


        comments{1}=getString(message(stringID));
    end
end
