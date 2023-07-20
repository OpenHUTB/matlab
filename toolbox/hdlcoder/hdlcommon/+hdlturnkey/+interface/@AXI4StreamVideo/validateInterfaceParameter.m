function validateInterfaceParameter(obj)




    validateInterfaceParameter@hdlturnkey.interface.AXI4StreamBase(obj,obj.RDAPIExampleStr);


    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.ImageWidth,'ImageWidth',obj.RDAPIExampleStr);
    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.ImageHeight,'ImageHeight',obj.RDAPIExampleStr);
    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.HorizontalPorch,'HorizontalPorch',obj.RDAPIExampleStr);
    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.VerticalPorch,'VerticalPorch',obj.RDAPIExampleStr);

end

