function exportWorkspace(obj)







    ExportArray=obj.CurrentArray;


    wsName=generateVariableName(obj);


    labels={[getString(message('phased:apps:arrayapp:exportvariable')),':']};
    vars={wsName};
    values={ExportArray};


    [~,okPressed]=export2wsdlg(labels,vars,values);
end
