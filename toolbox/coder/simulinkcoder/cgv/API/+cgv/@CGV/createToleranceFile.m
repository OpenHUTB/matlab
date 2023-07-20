


























function createToleranceFile(filename,signalList,toleranceList)






    if~ischar(filename)||nargin~=3
        DAStudio.error('RTW:cgv:BadParams');
    end
    if~iscellstr(signalList)
        DAStudio.error('RTW:cgv:SignalListError');
    end
    if length(signalList)~=length(toleranceList)
        DAStudio.error('RTW:cgv:LengthsMustMatch',length(signalList),length(toleranceList));
    end
    [~,~,ext]=fileparts(filename);
    if~isempty(ext)&&~strcmpi(ext,'.mat')
        DAStudio.error('RTW:cgv:MatFileOnly');
    end




    TolSave.ver=ver('Simulink');
    GlobalToleranceKey='global_tolerance';

    TolSave.Entry{1}.Key=GlobalToleranceKey;
    TolSave.Entry{1}.Type=1;
    TolSave.Entry{1}.absolute=0;
    TolSave.Entry{1}.relative=0;
    sdiUtil=Simulink.sdi.internal.Util;

    for i=1:length(signalList)
        signal=char(signalList{i});
        params=toleranceList{i};
        if length(params)~=2||~iscell(params)||~ischar(params{1})
            DAStudio.warning('RTW:cgv:BadToleranceFormat',i);
            continue;
        end
        type=char(params{1});
        value=params{2};
        switch lower(type)
        case 'absolute'
            sdiUtil.validateScalarNumericValue(value);
            TolSave.Entry{end+1}.Type=1;
            TolSave.Entry{end}.absolute=value;
        case 'relative'
            sdiUtil.validateScalarNumericValue(value);
            TolSave.Entry{end+1}.Type=1;
            TolSave.Entry{end}.relative=value;
        case 'function'
            TolSave.Entry{end+1}.Type=3;
            TolSave.Entry{end}.fcnCall=value;
        otherwise
            DAStudio.warning('RTW:cgv:BadToleranceFormat',i);
            continue;
        end
        TolSave.Entry{end}.Key=signal;

    end
    save(filename,'TolSave');
