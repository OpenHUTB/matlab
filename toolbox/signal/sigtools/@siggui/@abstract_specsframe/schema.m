function schema






    pk=findpackage('siggui');


    c=schema.class(pk,'abstract_specsframe',pk.findclass('sigcontainer'));
    set(c,'Description','abstract');


    p=schema.prop(c,'SFListeners','MATLAB array');
    set(p,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');


