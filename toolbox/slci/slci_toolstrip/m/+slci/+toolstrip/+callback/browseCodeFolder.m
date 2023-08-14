

function browseCodeFolder(cbinfo,action)
    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    curr_path=ctx.getCodeFolder;
    if isempty(curr_path)
        curr_path='.';
    end
    dir_name=uigetdir(curr_path);


    if dir_name~=0
        ctx.setCodeFolder(dir_name);

        action.selectedItem=dir_name;
        action.text=dir_name;
        action.name=dir_name;
        action.enabled=true;
    end
end