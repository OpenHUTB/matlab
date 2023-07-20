classdef ComponentSaveLinkViaUIGuard<handle

    methods
        function obj=ComponentSaveLinkViaUIGuard()
            inst=systemcomposer.internal.saveAndLink.SaveAndLinkDialog.instance();
            inst.setIsBlockConverting(true);
        end

        function delete(~)
            inst=systemcomposer.internal.saveAndLink.SaveAndLinkDialog.instance();
            inst.setIsBlockConverting(false);
        end
    end
end
