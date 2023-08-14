function exportFromEditor(backendRootUri,sequenceDiagramName)









    [mdlHandle,~]=builtin('_get_sl_object_instance_handle_from_sequence_diagram_uri','',backendRootUri);
    modelName=get_param(mdlHandle,'name');

    imageTypes={...
    sequencediagram.internal.print.ImageFormat.PDF;...
    sequencediagram.internal.print.ImageFormat.PNG;...
    sequencediagram.internal.print.ImageFormat.BMP;...
    sequencediagram.internal.print.ImageFormat.HDF;...
    sequencediagram.internal.print.ImageFormat.JPG;...
    sequencediagram.internal.print.ImageFormat.JPEG;...
    sequencediagram.internal.print.ImageFormat.JP2;...
    sequencediagram.internal.print.ImageFormat.RAS;...
    sequencediagram.internal.print.ImageFormat.TIF;...
    sequencediagram.internal.print.ImageFormat.TIFF;...
    };
    filters=strcat('*.',imageTypes);

    title=message('sequencediagram:Editor:PrintSequenceDiagramFilePickerTitle').getString();




    defName=[modelName,'_',sequenceDiagramName,'.',sequencediagram.internal.print.ImageFormat.PDF];

    [file,path]=uiputfile(filters,title,defName);

    canceled=isscalar(file)&&(file==0);
    if canceled
        return;
    end

    fullFilePath=fullfile(path,file);

    exporter=sequencediagram.internal.print.Exporter(modelName,sequenceDiagramName);
    exporter.export(fullFilePath);

end


