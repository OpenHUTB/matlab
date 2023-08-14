function name=getNameFromRenderedName(renderedName)











    name=Simulink.variant.utils.replaceNewLinesWithSpaces(regexprep(renderedName,'/','//'));
end
