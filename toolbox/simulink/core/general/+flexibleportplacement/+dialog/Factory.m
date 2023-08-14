classdef Factory




    methods(Access=private)
        function obj=Factory()
        end
    end

    methods(Static)
        function createDialog(block)
            spec=flexibleportplacement.specification.Factory.getSpecifiction(block);




            section=flexibleportplacement.dialog.EquallySpacedPortSection(spec);
            dialog=flexibleportplacement.dialog.Dialog(section);

            DAStudio.Dialog(dialog);
        end
    end
end

