function[studio,editor]=getCurrentStudio(~,subSys)
    studio=[];
    editor=[];
    editors=GLUE2.Util.findAllEditors(subSys);
    for idx=1:length(editors)
        if strcmpi(subSys,editors(idx).getName())
            studio=editors(idx).getStudio();
            editor=editors(idx);
        end
    end
end
