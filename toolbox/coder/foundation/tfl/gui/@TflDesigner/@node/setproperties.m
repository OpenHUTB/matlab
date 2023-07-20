function[success,errorid]=setproperties(this,dlghandle,tag)%#ok




    success=true;
    errorid='';

    try
        dlghandle.apply;

    catch ME
        success=false;
        errorid=ME.message;
    end







