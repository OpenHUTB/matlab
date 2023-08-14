function fmuHelp(block,openHelpPage)






    isLoaded=~isempty(get_param(block,'fmuWorkingDirectory'));
    do_display_help_page=openHelpPage&&isLoaded;
    if(do_display_help_page)
        help_page_dir=fullfile(fileparts(get_param(block,'fmuWorkingDirectory')),'help_page');
        help_page_file=fullfile(help_page_dir,'help_page.html');
        do_display_help_page=do_display_help_page&&2==exist(help_page_file,'file');
    end

    if(do_display_help_page)

        web(help_page_file);
    else







        helpview(fullfile(docroot,'simulink','helptargets.map'),'FMU_block');
    end
end


