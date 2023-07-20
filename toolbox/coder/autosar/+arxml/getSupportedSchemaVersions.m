function[schemaVersCell,schemaVersString]=getSupportedSchemaVersions()





    opts=autosar_rtwoptions_callback('GetOptions',[]);
    schemaVers=opts(strcmp('AutosarSchemaVersion',{opts(:).tlcvariable})).popupstrings;
    schemaVersCell=regexp([schemaVers,'|'],'.+?\|','match');
    schemaVersCell=strtok(schemaVersCell,'|');


    schemaVersString=strrep(schemaVers,'|',', ');


