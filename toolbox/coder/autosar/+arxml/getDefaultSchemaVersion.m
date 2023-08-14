function schemaVersionStr=getDefaultSchemaVersion()






    opts=autosar_rtwoptions_callback('GetOptions',[]);
    schemaVersionStr=opts(strcmp('AutosarSchemaVersion',{opts(:).tlcvariable})).default;
