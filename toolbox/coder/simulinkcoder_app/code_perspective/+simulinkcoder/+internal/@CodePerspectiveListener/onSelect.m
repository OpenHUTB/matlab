function onSelect(~,varargin)







    bd=varargin{1};
    mdl=bd.Name;


    ele=gsb(gcs,1);
    sid=Simulink.ID.getSID(ele);


    simulinkcoder.internal.util.model2code(mdl,sid);