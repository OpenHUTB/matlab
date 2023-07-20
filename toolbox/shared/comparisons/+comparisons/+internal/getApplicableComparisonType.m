function type=getApplicableComparisonType(file1,file2,requestedType)




    try
        error(javachk('jvm'));
        jFile1=java.io.File(comparisons.internal.resolvePath(file1));
        jFile2=java.io.File(comparisons.internal.resolvePath(file2));
        s1=com.mathworks.comparisons.source.impl.LocalFileSource(jFile1,jFile1.getAbsolutePath());
        s2=com.mathworks.comparisons.source.impl.LocalFileSource(jFile2,jFile2.getAbsolutePath());

        compatibleTypes=com.mathworks.comparisons.main.ComparisonTool.getInstance.getCompatibleComparisonTypes(s1,s2,[]);

        if compatibleTypes.length==0
            type="";
            return;
        end

        if nargin<3
            type=lower(string(compatibleTypes.get(0).getDataType().getName()));
            return;
        end

        if containsRequestedType(compatibleTypes,requestedType)
            type=requestedType;
        else
            type="";
        end
    catch err
        if strcmp(err.identifier,'comparisons:comparisons:FileNotFound')
            rethrow(err);
        end
        type="";
    end
end

function bool=containsRequestedType(compatibleTypes,requestedType)
    bool=false;
    for ii=0:compatibleTypes.size()-1
        if strcmpi(compatibleTypes.get(ii).getDataType().getName(),requestedType)
            bool=true;
            return
        end
    end
end
