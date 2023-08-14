function fpgaPropToSource(hObj)





    propNames=hObj.FPGAProperties.FPGAProjectPropertyName;
    propValues=hObj.FPGAProperties.FPGAProjectPropertyValue;
    propProcesses=hObj.FPGAProperties.FPGAProjectPropertyProcess;



    propNames=strread(propNames,'%s','delimiter',';');
    propValues=strread(propValues,'%s','delimiter',';');
    propProcesses=strread(propProcesses,'%s','delimiter',';');

    if(isempty(propNames))
        propRows=cell(0,3);
    else
        propRows=[propNames,propValues,propProcesses];
    end

    if isempty(hObj.FPGAProjectPropTableSource)
        hObj.FPGAProjectPropTableSource=tdkfpgacc.FPGAProjectPropTableSource('PropertyTable',propRows);
    else
        hObj.FPGAProjectPropTableSource.SetSourceData(propRows,1);
    end
