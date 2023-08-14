function edtWidget=makeEdit(h,name,obj,isObjMeth,method,rows,cols,enb,vis)




    edtWidget=makeWidget(h,name,obj,'edit',{},isObjMeth,method,rows,cols,enb,...
    vis,false);
end
