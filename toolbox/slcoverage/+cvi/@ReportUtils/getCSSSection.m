function outStr=getCSSSection()




    persistent linkStr;
    if isempty(linkStr)
        linkStr='<link rel="stylesheet" type="text/css" href="./scv_images/modelcovreport.css"/>';
    end

    outStr=linkStr;