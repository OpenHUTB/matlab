function tabOrNumeric=mustBeTabularOrNumericMatrix(x)

    tabOrNumeric=isa(x,'tabular')||...
    ((isnumeric(x)||isdatetime(x)||islogical(x)||isduration(x))&&ismatrix(x));
end