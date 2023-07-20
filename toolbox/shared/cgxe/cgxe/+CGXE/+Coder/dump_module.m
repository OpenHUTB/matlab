function file=dump_module(fileName,file,module,location,modelName)

    import CGXE.Coder.*;

    switch(location)
    case 'source'
        isSource=1;
    case 'header'
        isSource=0;
    otherwise,
        error('why');
    end

    fclose(file);
    cgxe('dump_module',fileName,isSource,modelName);
    file=fopen(fileName,'At');

    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end
