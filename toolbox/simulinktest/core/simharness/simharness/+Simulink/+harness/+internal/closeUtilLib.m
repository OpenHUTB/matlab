function closeUtilLib
    if any(strcmp(find_system('type','block_diagram'),'sltestutillib'))
        close_system('sltestutillib',0);
    end
end
