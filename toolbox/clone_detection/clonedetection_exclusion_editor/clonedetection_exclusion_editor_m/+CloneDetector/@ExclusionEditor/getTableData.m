function result=getTableData(this)




    if~this.isTableDataValid
        this.fetchDataFromBackend();
    end
    result=this.TableData;
end
