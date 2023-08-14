function launchXMLComparison(filePath1,filePath2)



    import com.mathworks.toolbox.rptgenxmlcomp.util.XMLCompUtils;
    if XMLCompUtils.wouldCompareWithBasicXMLComparisonType(filePath1,filePath2)
        visdiff(filePath1,filePath2,'XML');
    else
        visdiff(filePath1,filePath2);
    end
end

