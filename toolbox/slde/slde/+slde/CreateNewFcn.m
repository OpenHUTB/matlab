function CreateNewFcn(block,fcn_prototype)
    system=get_param(block,'parent');
    fcnblk=add_block('simulink/User-Defined Functions/Simulink Function',[system,'/Simulink Function'],'MakeNameUnique','on');
    set_param(fcnblk,'FunctionPrototype',fcn_prototype);
    xy=get_param(block,'position');
    ab=get_param(fcnblk,'position');
    set_param(fcnblk,'position',[xy(1),xy(4)+40,xy(1)+(ab(3)-ab(1)),xy(4)+40+(ab(4)-ab(2))]);
    set_param(block,'position',xy);
end