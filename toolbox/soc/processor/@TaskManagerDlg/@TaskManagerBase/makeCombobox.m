function cmbWidget=makeCombobox(h,label,obj,entries,isObjMeth,method,rows,cols,enb,vis)




    cmbWidget=makeWidget(h,label,obj,'combobox',entries,isObjMeth,method,...
    rows,cols,enb,vis,false);
end
