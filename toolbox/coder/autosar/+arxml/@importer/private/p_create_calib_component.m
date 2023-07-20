function p_create_calib_component(this,argParser)





    p_update_read(this);

    args={...
    'NameConflictAction',argParser.Results.NameConflictAction,...
    'CreateSimulinkObject',argParser.Results.CreateSimulinkObject,...
    'DataDictionary',argParser.Results.DataDictionary,...
    'UseLegacyWorkspaceBehavior',argParser.Results.UseLegacyWorkspaceBehavior};



    m3iSwcTiming=Simulink.metamodel.arplatform.timingExtension.SwcTiming.empty;


    builderChangeLogger=autosar.updater.ChangeLogger();
    xmlOptsGetter=autosar.mm.util.XmlOptionsGetter(this.arModel);
    arDictionaryFile='';
    builder=autosar.mm.mm2sl.ModelBuilder(this.arModel,...
    argParser.Results.DataDictionary,arDictionaryFile,builderChangeLogger,...
    xmlOptsGetter,m3iSwcTiming);
    builder.createCalibrationComponentObjects(argParser.Results.ComponentName,args{:});


