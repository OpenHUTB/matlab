



classdef Component_Vendor<dds.internal.ui.app.base.OptionBase

    properties(Hidden,Constant)
        ID='Component_Vendor';
    end

    methods
        function obj=Component_Vendor(env)






            id=dds.internal.ui.app.option.Component_Vendor.ID;
            obj@dds.internal.ui.app.base.OptionBase(id,env);

            obj.OptionMessage=DAStudio.message('dds:toolstrip:uiWizardVendorName');

            obj.Type='combobox';
            obj.Indent=1;

            reg=dds.internal.vendor.DDSRegistry;
            lst=reg.getVendorList;
            obj.Value={lst(:).DisplayName};
            obj.Answer=find(strcmp(obj.Value,env.VendorName));
        end

        function out=isEnabled(obj)
            out=true;
        end

        function ret=onNext(obj)


            ret=0;

            reg=dds.internal.vendor.DDSRegistry;
            lst=reg.getVendorList;
            obj.Env.VendorName=lst(obj.Answer).DisplayName;
            obj.Env.VendorKey=lst(obj.Answer).Key;
            ent=reg.getEntryFor(obj.Env.VendorKey);
            obj.Env.VendorSupportsIDLAndXML=isfield(ent,'ImportXMLAndIDL')&&...
            ~isempty(ent.ImportXMLAndIDL);
        end

    end
end


