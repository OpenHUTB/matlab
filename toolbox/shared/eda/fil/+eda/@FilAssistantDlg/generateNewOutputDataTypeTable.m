function generateNewOutputDataTypeTable(this,dlg)









    l_constructPortTable(this);

end

function l_constructPortTable(this)

    this.NewOutputDataTypeTableData=cell(0,5);
    this.Status='';
    for ii=1:size(this.PortTableData,1)
        row=this.PortTableData(ii,:);
        if(row{1,2}.Value==1)&&(row{1,4}.Value==0)
            this.addNewOutputDataType(row{1,1},row{1,3},'Fixedpoint','Unsigned','0',true)
        end
    end

end