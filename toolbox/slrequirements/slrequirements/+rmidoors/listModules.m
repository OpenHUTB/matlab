function modules_info=listModules(projectName)






    if nargin==0
        projectName='/';
    elseif projectName(1)~='/'
        warning(message('Slvnv:reqmgt:doors_list_modules:AbsoluteProjectNameExpected'));
        projectName=['/',projectName];
    end

    hDoors=rmidoors.comApp;
    rmidoors.invoke(hDoors,['dmiListModules_("',projectName,'")']);
    modules_info=eval(hDoors.Result);
    if ischar(modules_info)
        warning(message('Slvnv:reqmgt:doors_list_modules:ListModulesFailed',modules_info));
        modules_info={};
    elseif~isempty(modules_info)
        is_links_module=strcmp(modules_info(:,3),'DOORS Links');
        modules_info(is_links_module,:)=[];
    end
end



