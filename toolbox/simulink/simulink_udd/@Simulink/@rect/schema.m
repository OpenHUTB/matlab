function schema


















    slPkg=findpackage('Simulink');




    c=schema.class(slPkg,'rect');




    pLeft=schema.prop(c,'left','int32');
    pTop=schema.prop(c,'top','int32');
    pRight=schema.prop(c,'right','int32');
    pBottom=schema.prop(c,'bottom','int32');

