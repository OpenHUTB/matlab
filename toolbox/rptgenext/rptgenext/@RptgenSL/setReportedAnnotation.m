function setReportedAnnotation(annotation)





    type=get_param(annotation,'Type');
    assert(strcmp(type,'annotation'));

    set(rptgen_sl.appdata_sl,'CurrentAnnotation',annotation);
