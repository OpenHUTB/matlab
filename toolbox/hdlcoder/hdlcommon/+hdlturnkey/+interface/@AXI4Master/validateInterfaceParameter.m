function validateInterfaceParameter(obj)






    if obj.IsGenericIP
        if~isempty(obj.InterfaceConnection)
            error(message('hdlcommon:interface:AXIMasterGenericIPNotSupport','InterfaceConnection'));
        end
        if~isempty(obj.TargetAddressSegments)
            error(message('hdlcommon:interface:AXIMasterGenericIPNotSupport','TargetAddressSegments'));
        end
    else
        hdlturnkey.plugin.validateRequiredStringProperty(...
        obj.InterfaceConnection,'InterfaceConnection',obj.ExampleStr);
    end

    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.MaxDataWidth,'MaxDataWidth',obj.ExampleStr);








    hdlturnkey.plugin.validatePowerOfTwo(...
    obj.MaxDataWidth,'MaxDataWidth',obj.ExampleStr);
    AXIMasterDataWidthRange=[8,1024];
    hdlturnkey.plugin.validateValueWithinRange(...
    obj.MaxDataWidth,'MaxDataWidth',AXIMasterDataWidthRange,obj.ExampleStr);


    hdlturnkey.plugin.validateIntegerRangeProperty(...
    obj.AddrWidth,'AddrWidth',0,32,obj.ExampleStr);

    hdlturnkey.plugin.validateNonNegIntegerProperty(...
    obj.MaxLenWidth,'MaxLenWidth',obj.ExampleStr);


    hdlturnkey.plugin.validateBooleanProperty(...
    obj.ReadSupport,'ReadSupport',obj.ExampleStr);

    hdlturnkey.plugin.validateBooleanProperty(...
    obj.WriteSupport,'WriteSupport',obj.ExampleStr);

    if~obj.ReadSupport&&~obj.WriteSupport
        error(message('hdlcommon:interface:AXIMasterNoReadWrite'));
    end


    if~iscell(obj.TargetAddressSegments)
        error(message('hdlcommon:interface:AXIMasterTgtAddrSegFmt',obj.ExampleStr));
    end

    for ii=1:numel(obj.TargetAddressSegments)
        tgtSeg=obj.TargetAddressSegments{ii};
        if numel(tgtSeg)~=3||...
            ~ischar(tgtSeg{1})||...
            ~(isnumeric(tgtSeg{2})&&tgtSeg{2}>=0)||...
            ~(isnumeric(tgtSeg{3})&&tgtSeg{3}>=0)
            error(message('hdlcommon:interface:AXIMasterTgtAddrSegFmt',obj.ExampleStr));
        end
    end

end



