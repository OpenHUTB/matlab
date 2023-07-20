function out=update_cap(hBlock)






    set_param(hBlock,'Commented','on')


    h=get_param(hBlock,'LineHandles');
    if h.LConn~=-1
        delete_line(h.LConn);
    end


    beginning_variables=HtoIL_collect_vars(hBlock,{'p'},'fl_lib/Hydraulic/Hydraulic Elements/Hydraulic Cap');

    if(strcmp(beginning_variables(1).specify,'off')&&~strcmp(beginning_variables(1).unspecified_priority,'None'))||...
        (strcmp(beginning_variables(1).specify,'on')&&~strcmp(beginning_variables(1).priority,'None'))

        removed_block_warning.messages={'Consider adjusting the initial pressure in a previously connected block.'};
    else
        removed_block_warning.messages={'Behavior change not expected.'};
    end

    removed_block_warning.subsystem=getfullname(hBlock);

    out.removed_block_warning=removed_block_warning;

end



