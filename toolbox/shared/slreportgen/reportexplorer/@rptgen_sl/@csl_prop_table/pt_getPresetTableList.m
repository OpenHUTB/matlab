function tList=pt_getPresetTableList(c)






    switch lower(c.ObjectType)
    case 'model'
        tList={
'Simulation Parameters'
'Version Information'
'Simulink Coder Information'
        };

        if strcmp(get_param(0,'RtwLicensed'),'on')
            tList{end+1}='Summary (req. Simulink Coder)';
        end

    case 'system'
        tList={'Mask Properties'
'System Signals'
        'Print Properties'};
    case 'block'
        tList={'Block Signals'
        'Mask Properties'};
    case 'annotation'
        tList={};
    case 'configset'
        tList={};
    case 'signal'
        tList={'Complete'
        'Compiled Information'};
    otherwise
        tList={};
    end

    tList=[{'Default'};tList;{'Blank 4x4'}];
