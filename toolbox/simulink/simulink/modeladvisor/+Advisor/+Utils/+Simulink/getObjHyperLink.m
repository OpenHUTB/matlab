function link=getObjHyperLink(obj)






    tbl=ModelAdvisor.FormatTemplate('TableTemplate');
    link=tbl.formatEntry(obj);
    link.Content=obj.getFullName();
end