function[pValue,propName]=getPropValue(ps,objList,propName)





    switch propName
    case ps.getCommonPropValue('PropList')



        [pValue,propName]=getCommonPropValue(ps,objList,propName);

    case{'SnapshotSmall','SnapshotLarge'}
        d=get(rptgen.appdata_rg,'CurrentDocument');
        cSnapshot=rptgen_sl.csl_sys_snap;
        if strcmpi(propName(end-4:end),'small')
            set(cSnapshot,...
            'PaperExtentMode','manual',...
            'PaperExtent',[2,2],...
            'PaperUnits','inches',...
            'ViewportType','none',...
            'CreateImagemap',false);
        else
            set(cSnapshot,...
            'PaperExtentMode','manual',...
            'PaperExtent',[6,6],...
            'PaperUnits','inches',...
            'ViewportType','none',...
            'CreateImagemap',true);
        end

        if ischar(objList)
            objList={objList};
        end
        for i=length(objList):-1:1
            try
                pValue{i,1}=gr_makeGraphic(cSnapshot,d,objList{i});
            catch ME
                pValue{i,1}='N/A';
                cSnapshot.status(ME.message,2);
            end
        end
        propName='Snapshot';
    case 'SampleTimes'
        warnID='Simulink:Engine:CompileNeededForSampleTimes';
        warnState=warning('query',warnID);
        warning('off',warnID);
        scopedWarningRestore=onCleanup(@()warning(warnState));
        pValue=rptgen.safeGet(objList,propName,'get_param');

    otherwise
        pValue=rptgen.safeGet(objList,propName,'get_param');
    end
