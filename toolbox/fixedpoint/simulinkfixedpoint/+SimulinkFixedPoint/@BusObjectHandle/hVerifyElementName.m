function hVerifyElementName(h,elementName)




    if~h.leafChildName2IndexMap.isKey(elementName)

        msg=DAStudio.message(...
        'SimulinkFixedPoint:autoscaling:InValidBusElementName',elementName);
        ME=MException('SimulinkFixedPoint:autoscaling:InValidBusElementName',...
        msg);

        throw(ME);
    end




