classdef DockableWebBrowserConfig




    properties
        ModelStudioGetter=@simulink.multisim.internal.getAllStudiosForModel
        SchemaConstructor=@simulink.multisim.internal.WebBrowserSchema
        DDGComponentConstructor=@GLUE2.DDGComponent
    end
end