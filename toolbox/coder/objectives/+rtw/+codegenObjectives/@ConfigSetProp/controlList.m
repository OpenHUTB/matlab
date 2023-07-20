function ctrl=controlList(obj)



    ctrl.name{1}='ERTTarget';
    ctrl.id{1}='1';


    name='CPPClassGenCompliant';
    idx=1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='false';

    name='CustomSymbolStr';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrBlockIO';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrFcn';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrField';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrGlobalVar';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrMacro';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrTmpVar';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='CustomSymbolStrType';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='default';

    name='DefineNamingRule';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='none';

    name='ERTCustomFileBanners';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='GenerateSampleERTMain';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='false';

    name='GenerateTestInterfaces';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='false';

    name='GenerateTraceInfo';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='GenerateTraceReport';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='GenerateTraceReportEml';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='GenerateTraceReportSf';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='GenerateTraceReportSl';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='IgnoreCustomStorageClasses';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='IncludeHyperlinkInReport';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='IncludeMdlTerminateFcn';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='InlinedPrmAccess';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='literals';

    name='InternalIdentifier';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='Shortened';

    name='InsertBlockDesc';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='ModelStepFunctionPrototypeControlCompliant';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='false';

    name='NoFixptDivByZeroProtection';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='OptimizeModelRefInitCode';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='ParamNamingRule';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='none';

    name='ParenthesesLevel';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='nominal';

    name='PortableWordSizes';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='PurelyIntegerCode';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='false';

    name='SFDataObjDesc';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='SignalNamingRule';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='none';

    name='SimulinkDataObjDesc';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='SupportAbsoluteTime';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='SupportComplex';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='SupportContinuousTime';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='SupportNonInlinedSFcns';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='SuppressErrorStatus';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='off';

    name='ZeroExternalMemoryAtStartup';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    name='ZeroInternalMemoryAtStartup';
    idx=idx+1;
    ctrl.params{1}{idx}.param=name;
    ctrl.params{1}{idx}.id=loc_lookupId(name,obj);
    ctrl.params{1}{idx}.setting='on';

    ctrl.len{1}=length(ctrl.params{1});

end

function id=loc_lookupId(param,obj)
    id=obj.ParamHash.get(param);
end


