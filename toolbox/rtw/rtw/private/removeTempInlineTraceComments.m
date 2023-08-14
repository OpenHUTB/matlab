function output=removeTempInlineTraceComments(str)


    output=regexprep(str,'\/\*@[\[\]><][a-zA-Z0-9]*\*\/','');
end

