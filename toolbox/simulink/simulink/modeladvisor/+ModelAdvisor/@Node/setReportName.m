function valueStored=setReportName(this,valueProposed)%#ok<INUSL>




    if strcmpi(valueProposed,'report.html')
        DAStudio.error('Simulink:tools:MAValueisReserved','report.html');
    else
        valueStored=valueProposed;
    end