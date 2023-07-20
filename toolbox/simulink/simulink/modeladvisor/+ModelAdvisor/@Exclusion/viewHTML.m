function viewStr=viewHTML(this,str)




    checkIDString='{';
    checkIDs=this.CheckIDs;
    for i=1:length(checkIDs)
        checkIDString=[checkIDString,checkIDs{i},', '];
    end
    checkIDString=deblank(checkIDString);
    checkIDString(end)='}';
    viewStr='';

    table=ModelAdvisor.Table(length(checkIDs)+1,2);
    table.setEntry(1,1,['<b>     ',DAStudio.message('ModelAdvisor:engine:ExclusionName'),'<b/>']);
    Rationale=this.Rationale;



    if strcmp(str,'model')
        str=[' ',DAStudio.message('ModelAdvisor:engine:SpecificExclusions')];
    else
        str='';
    end
    table.setEntry(1,2,[Rationale,str]);

    for i=1:length(checkIDs)
        table.setEntry(i+1,1,'')
        table.setEntry(i+1,2,checkIDs{i})
    end
    table.setEntry(2,1,['<b>',DAStudio.message('ModelAdvisor:engine:ExclusionCheckIDs'),'<b/>']);
    table.setBorder(0);
    viewStr=table.emitHTML;