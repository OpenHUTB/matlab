classdef ModelCallbackHandler<dependencies.internal.action.DependencyHandler




    properties(Constant)
        Types="ModelCallback";
    end

    methods
        function unhilite=openUpstream(~,dependency)
            unhilite=@()[];

            if i_isDefinedViaModelPropertyUI(dependency.Type)
                location=dependency.UpstreamNode.Location{1};
                [~,filename,~]=fileparts(location);
                h=get_param(filename,'Object');
                dlg=DAStudio.Dialog(h);
                dlg.setActiveTab('Tabcont',1);
            end
        end
    end
end

function bool=i_isDefinedViaModelPropertyUI(type)
    types=type.Parts;
    bool=length(types)<2||~strcmp(types(2),"PostCodeGenCommand");
end


