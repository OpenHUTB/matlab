function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractps',...
    pk.findclass('abstractfreqrespwspectrumtype'));


    schema.prop(c,'ConfLevel','mxArray');


    schema.prop(c,'ConfInterval','twocol_nonneg_matrix');


