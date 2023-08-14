function section=createExternalToolboxesListSection(this,docType)




    title=getResource("ExternalToolboxListTitle");
    names=arrayfun(@getNameFromToolboxNode,this.ToolboxNodes);
    section=createListSection(2,title,names,docType);
end
