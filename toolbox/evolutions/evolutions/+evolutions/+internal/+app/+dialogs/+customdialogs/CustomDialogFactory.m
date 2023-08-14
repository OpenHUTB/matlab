classdef CustomDialogFactory<handle




    methods(Static=true)
        function dialog=getCustomDialog(type,userData)
            switch type
            case 'EvolutionName'
                dialog=evolutions.internal.app.dialogs.customdialogs.GetName...
                ('Evolution Name');
            case 'EvolutionTreeName'
                dialog=evolutions.internal.app.dialogs.customdialogs.GetName...
                ('Evolution Tree Name');
            case 'LayoutName'
                dialog=evolutions.internal.app.dialogs.customdialogs.GetName...
                (getString(message('evolutions:ui:LayoutName')));
            case 'GenerateReport'
                dialog=evolutions.internal.app.dialogs.customdialogs.GenerateReport(userData);
            otherwise
                assert(strcmp(type,'OrganizeLayout'));
                dialog=evolutions.internal.app.dialogs.customdialogs.OrganizeLayout;
            end
        end
    end
end
