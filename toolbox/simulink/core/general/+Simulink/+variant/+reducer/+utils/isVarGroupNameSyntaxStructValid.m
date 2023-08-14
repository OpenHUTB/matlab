function[isValid,variableGroups]=isVarGroupNameSyntaxStructValid(variableGroups)










    fieldNamesVariableGroups=fieldnames(variableGroups);
    isValid=(numel(fieldNamesVariableGroups)==2)&&(size(variableGroups,1)==1)&&...
    (strcmpi(fieldNamesVariableGroups{1},'Name')&&strcmpi(fieldNamesVariableGroups{2},'VariantControls'))&&...
    all(arrayfun(@(X)((isa(X.(fieldNamesVariableGroups{1}),'char')||isa(X.(fieldNamesVariableGroups{1}),'string'))&&...
    isa(X.(fieldNamesVariableGroups{2}),'cell')),variableGroups));

    if isValid&&(nargout==2)


        charConversionFcn=@(Y)cellfun(@(X)(char(X)),Y,'UniformOutput',false);
        for i=1:numel(variableGroups)
            variableGroups(i).(fieldNamesVariableGroups{1})=char(variableGroups(i).(fieldNamesVariableGroups{1}));
            variableGroups(i).(fieldNamesVariableGroups{2})(1:2:end-1)=deal(charConversionFcn(variableGroups(i).(fieldNamesVariableGroups{2})(1:2:end-1)));
        end
    end
end
