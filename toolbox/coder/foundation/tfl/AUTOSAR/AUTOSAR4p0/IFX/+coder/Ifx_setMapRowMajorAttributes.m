function[hEnt,algPropertyList]=Ifx_setMapRowMajorAttributes(hEnt,algPropertyList,createRowMajorRoutine)


    if~createRowMajorRoutine
        hEnt.ArrayLayout='COLUMN_MAJOR';
        algPropertyList{end+1}={'UseRowMajorAlgorithm','off'};
    else
        hEnt.ArrayLayout='ROW_MAJOR';
        algPropertyList{end+1}={'UseRowMajorAlgorithm','on'};
    end
