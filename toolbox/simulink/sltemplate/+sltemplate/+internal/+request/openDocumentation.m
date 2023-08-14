function openDocumentation(key)

    switch key
    case 'SimulinkDocumentation'
        i_mapped('collection');
    case 'CreateTemplate'
        i_mapped('export_to_template');
    case 'SettingDefaultModelTemplate'
        i_mapped('default_model_template');
    case 'BlockReference'
        i_mapped('blocks')
    case 'GettingStarted'
        i_unmapped(fullfile(docroot,'simulink','getting-started-with-simulink.html'));
    case 'ReleaseNotes'
        i_unmapped(fullfile(docroot,'simulink','release-notes.html'));
    case 'ExamplesHome'
        i_unmapped(fullfile(docroot,'examples.html'));
    otherwise
        i_mapped('collection');
    end
end

function i_mapped(key)
    sltemplate.internal.request.openMappedDocumentation(key);
end

function i_unmapped(address)
    helpview(address);
end
