function storeDockedReport(this,dr)






    key=dr.getStorageKey();

    oldDRList=[];
    if this.dockedReports.isKey(key)
        oldDRList=this.dockedReports(key);
    end
    this.dockedReports(key)=[oldDRList,dr];
end