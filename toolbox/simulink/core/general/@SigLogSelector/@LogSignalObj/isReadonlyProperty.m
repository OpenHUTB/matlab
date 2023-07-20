function bReadOnly=isReadonlyProperty(h,propName)







    bReadOnly=false;



    if isempty(h.hParent)||~h.isEditableProperty(propName)
        return;
    end


    if strcmp(propName,'DataLogging')
        bReadOnly=h.hParent.logAsSpecified;
        return;
    end


    val=h.getPropValue('DataLogging');
    if strcmp(val,'off')
        bReadOnly=true;
        return;
    end




    switch propName


    case{'LoggingName'}
        val=h.getPropValue('NameMode');
        str=DAStudio.message('Simulink:Logging:SigLogDlgNameModeFalse');
        bReadOnly=strcmp(val,str);


    case{'Decimation'}
        val=h.getPropValue('DecimateData');
        bReadOnly=strcmp(val,'off');


    case{'MaxPoints'}
        val=h.getPropValue('LimitDataPoints');
        bReadOnly=strcmp(val,'off');

    end



    if~bReadOnly
        bReadOnly=h.hParent.logAsSpecified;
    end

end

