function[result,msgString,description]=nesl_isvalidsimscapecomponent(componentName)








    [result,msgString,description]=...
    simscape.internal.dialog.isValidSimscapeComponent(componentName);

end
