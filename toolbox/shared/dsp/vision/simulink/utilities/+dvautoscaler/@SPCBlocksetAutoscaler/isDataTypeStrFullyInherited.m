function result=isDataTypeStrFullyInherited(h,specifiedDTStr)%#ok




    result=~isempty(regexp(specifiedDTStr,'^(Inherit |Inherit:|Same as|Same word|Smallest )','ONCE'));


