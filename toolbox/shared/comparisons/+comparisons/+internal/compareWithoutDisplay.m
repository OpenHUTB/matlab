function out=compareWithoutDisplay(filename1,filename2,showchars)












    if isTextComparison(filename1,filename2)
        out=comparisons_private('textdiff',filename1,filename2,showchars);
        return
    end

    out=comparisons.internal.api.compare(filename1,filename2);
end

function bool=isTextComparison(filename1,filename2)
    import com.mathworks.comparisons.matlab.MATLABAPIUtils;

    files=comparisons.internal.resolveFiles(filename1,filename2);
    bool=MATLABAPIUtils.isTextComparison(files.Left,files.Right);
end
