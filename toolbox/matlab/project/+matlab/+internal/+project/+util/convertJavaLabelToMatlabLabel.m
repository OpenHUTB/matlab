function mLabel=convertJavaLabelToMatlabLabel(jLabel)






    import matlab.project.LabelDefinition;

    labelName=char(jLabel.getName());
    categoryName=char(jLabel.getCategory().getName());

    mLabel=LabelDefinition(categoryName,labelName);

end

