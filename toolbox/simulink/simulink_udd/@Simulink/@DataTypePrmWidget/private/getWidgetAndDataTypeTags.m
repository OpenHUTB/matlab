function[widgetTag,dtTag]=getWidgetAndDataTypeTags(tag)







    [dtTag,remainder]=strtok(tag,'|');
    widgetTag=remainder(2:end);



