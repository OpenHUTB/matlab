function viewStr=view(this)




    checkIDString='{';
    checkIDs=this.CheckIDs;
    for i=1:length(checkIDs)
        checkIDString=[checkIDString,checkIDs{i},', '];
    end
    checkIDString=deblank(checkIDString);
    checkIDString(end)='}';
    viewStr='';
    newLine=sprintf('\n');
    descriptionStr=this.Rationale;
    if~strcmp(descriptionStr,'')
        descriptionStr=['Rationale:   ',this.Rationale,newLine];
    end

    RuleStr='';
    RuleObjList=this.Rules;
    for i=1:length(RuleObjList)
        RuleStr=[RuleStr,'RuleType:',RuleObjList(i).Type];
        NameList=RuleObjList(i).Name;
        Name='';Value='';
        for j=1:length(NameList)
            Name=[Name,',',NameList{j}];
        end
        ValueList=RuleObjList(i).Value;
        for j=1:length(ValueList)
            Value=[Value,',',ValueList{j}];
        end
        RuleStr=[RuleStr,newLine];
        if~isempty(Name)
            RuleStr=[RuleStr,'RuleName:',Name];
            RuleStr=[RuleStr,newLine];
        end
        RuleStr=[RuleStr,'RuleValue:',Value];
        RuleStr=[RuleStr,newLine,'--------------',newLine];
    end
    RuleStr=['--------------',newLine,RuleStr];
    viewStr=[viewStr,descriptionStr,'Exclusion :',this.Rationale,newLine,RuleStr,'CheckIDs:',checkIDString,newLine,'******************************'];
