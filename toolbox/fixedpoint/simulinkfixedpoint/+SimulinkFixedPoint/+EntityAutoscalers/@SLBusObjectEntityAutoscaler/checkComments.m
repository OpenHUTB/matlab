function comment=checkComments(~,busObjectHandle,pathItem)




    comment='';

    if~busObjectHandle.leafChildName2IndexMap.isKey(pathItem)
        comment{1}=DAStudio.message(...
        'SimulinkFixedPoint:autoscaling:InValidBusElementName',pathItem);
    end

end


