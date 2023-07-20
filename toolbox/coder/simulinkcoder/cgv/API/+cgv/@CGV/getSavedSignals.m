


















function list=getSavedSignals(dataSet)



    if(nargin~=1)
        DAStudio.error('RTW:cgv:BadParams');
    end

    sdie=Simulink.sdi.Instance.engine;

    srcName=inputname(1);
    if isempty(srcName)
        DAStudio.error('RTW:cgv:ComplexName','','getSavedSignals','');
    end

    if~Simulink.sdi.internal.Util.IsSDISupportedType(dataSet)
        DAStudio.error('RTW:cgv:UnsupportedDataType',srcName);
    end


    Run1ID=sdie.createRunFromNamesAndValues('Run 1',{srcName},{dataSet});
    list=cgv.CGV.dataSrcsList(sdie,Run1ID);
    if nargout==0
        disp(char(list));
    end
