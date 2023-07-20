function obj=bsw_create_dialog(h,className)








    assert(strcmp(get_param(h,'BlockType'),'SubSystem'),...
    'h must be a SubSystem');
    obj=bswdialog.(className{1})(h);
