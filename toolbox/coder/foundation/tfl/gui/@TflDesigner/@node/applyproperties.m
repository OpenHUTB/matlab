function[success,error]=applyproperties(this,dlghandle)




    success=true;
    error='';
    try

        me=TflDesigner.getexplorer;

        root=me.getRoot;

        root.iseditorbusy=true;

        this.setPropValue('Tfldesigner_Name',dlghandle.getWidgetValue('Tfldesigner_Name'));

        root.iseditorbusy=false;

    catch ME
        success=false;
        error=ME.message;

    end

