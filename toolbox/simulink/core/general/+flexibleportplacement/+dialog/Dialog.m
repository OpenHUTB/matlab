classdef Dialog<handle




    properties
SpecifictionSection
    end

    methods
        function obj=Dialog(specSection)
            obj.SpecifictionSection=specSection;
        end

        function dlgstruct=getDialogSchema(obj,~)

            headerStructs=obj.getDialogHeader();
            specItems=obj.SpecifictionSection.getSectionItems();


            dlgstruct.DialogTag='PositionPortsDialog';
            dlgstruct.DialogTitle=DAStudio.message('Simulink:dialog:FPPPositionPorts');
            dlgstruct.Items=[headerStructs,specItems];
            dlgstruct.PostApplyMethod='postApplyCallback';
            dlgstruct.PostApplyArgs={'%dialog'};
            dlgstruct.PostApplyArgsDT={'handle'};
            dlgstruct.OpenCallback=@(dlg)obj.openCallback(dlg);
            dlgstruct.CloseMethod='closeCallback';
        end

        function postApplyCallback(obj,~)
            obj.SpecifictionSection.applySpecification();
        end

        function openCallback(obj,dlg)
            obj.SpecifictionSection.openCallback(dlg);
        end

        function closeCallback(obj)
            obj.SpecifictionSection.closeCallback();
        end
    end

    methods(Access=private)
        function headerStructs=getDialogHeader(~)
            titleText.Type='text';
            titleText.Name=DAStudio.message('Simulink:dialog:FPPPositionPorts');

            headerStructs={titleText};
        end
    end
end


