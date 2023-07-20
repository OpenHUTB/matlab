function[success,errorid]=applyproperties(this,dlghandle)%#ok






    success=true;
    errorid='';

    selection=dlghandle.getWidgetValue('Tfldesigner_EntrySelection');

    switch selection
    case 0
        TflDesigner.cba_addtflcop;
    case 1
        TflDesigner.cba_addtflcfunc;
    case 2
        TflDesigner.cba_addtflblas;
    case 3
        TflDesigner.cba_addtflcblas;
    case 4
        TflDesigner.cba_addtflcopgennet;
    case 5
        TflDesigner.cba_addtflcsementry;
    case 6
        TflDesigner.cba_addtflcustomization;
    otherwise
        success=false;
    end

    delete(dlghandle);

