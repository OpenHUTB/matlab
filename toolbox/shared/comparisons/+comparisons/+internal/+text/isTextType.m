function bool=isTextType(file1,file2,varargin)




    [~,~,ext1]=fileparts(file1);
    [~,~,ext2]=fileparts(file2);

    import comparisons.internal.getApplicableComparisonType
    textType=com.mathworks.comparisons.register.datatype.CDataTypeText.getInstance();
    bool=strcmpi(textType.getName(),getApplicableComparisonType(file1,file2,varargin{:}))...
    &&~strcmpi(ext1,'.mlx')...
    &&~strcmpi(ext2,'.mlx');
end
