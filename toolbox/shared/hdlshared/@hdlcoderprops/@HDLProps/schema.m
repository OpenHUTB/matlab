function schema









    mlock;

    pkg=findpackage('hdlcoderprops');
    c=schema.class(pkg,'HDLProps');

    findclass(findpackage('propset'),'tree');
    findclass(pkg,'CLI');


    schema.prop(c,'INI','propset.tree');


    schema.prop(c,'CLI','hdlcoderprops.CLI');

    p=schema.prop(c,'TargetLanguageListener','handle.listener');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off',...
    'AccessFlags.Serialize','off');
