classdef LibraryLinkHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.LibraryLinksAnalyzer.LibraryLinkType.ID);
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)

            [~,library]=fileparts(newPath);
            [~,downPath]=strtok(dependency.DownstreamComponent.Path,"/");
            ref=library+downPath;


            if strcmp(dependency.UpstreamNode.Location{1},newPath)
                [~,upPath]=strtok(dependency.UpstreamComponent.Path,"/");
                block=library+upPath;
            else
                block=dependency.UpstreamComponent.Path;
            end

            params=get_param(block,'DialogParameters');
            current=get_param(block,'ReferenceBlock');

            if isfield(params,'TemplateBlock')&&isempty(current)

                i_refactorConfigurableSubsystem(block,char(ref));

            elseif isfield(params,'SourceBlock')

                set_param(block,'SourceBlock',ref);

            else

                set_param(block,'ReferenceBlock',ref);
            end
        end

    end

end


function i_refactorConfigurableSubsystem(block,ref)



    params=get_param(block,'ObjectParameters');
    names=fieldnames(params);
    values=cellfun(@(p)get_param(block,p),names,'UniformOutput',false);


    slInternal('replace_block',block,ref,'KeepSID','on');


    for n=1:length(names)
        try %#ok<TRYNC>
            set_param(block,names{n},values{n});
        end
    end

end
