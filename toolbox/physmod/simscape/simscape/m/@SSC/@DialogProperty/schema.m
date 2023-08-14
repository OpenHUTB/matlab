function schema





    pkg=findpackage('SSC');
    cls=schema.class(pkg,'DialogProperty');

    schema.prop(cls,'Name','ustring');
    schema.prop(cls,'Label','ustring');
    schema.prop(cls,'Group','ustring');
    schema.prop(cls,'GroupDesc','ustring');
    schema.prop(cls,'WidgetType','ustring');
    schema.prop(cls,'Eval','bool');
    schema.prop(cls,'Entries','string vector');
    schema.prop(cls,'IsUnit','bool');
    schema.prop(cls,'HasUnit','bool');
    schema.prop(cls,'Enabled','MATLAB array');
    schema.prop(cls,'MatlabMethod','MATLAB array');
    schema.prop(cls,'DefaultValue','MATLAB array');
    schema.prop(cls,'RowWithButton','bool');

end



