function addUserHook(hThisObj,hook,commandString)










    warnID='Simulink:mpt:RTWBuildCustomizer:addUserHook';

    if~(exist('make_rtw.m','file')==2||exist('make_rtw.p','file')==6)
        persistent diswarn
        if isempty(diswarn)
            MSLDiagnostic('Simulink:mpt:MPTRequireRTW',mfilename).reportAsWarning;
            diswarn=1;
        end
        return
    end

    [hook,commandString]=convertStringsToChars(hook,commandString);
    if~ischar(hook)
        MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',mfilename).reportAsWarning;
        return
    end

    hook=strtrim(hook);

    if~isvarname(hook)||...
        (~(ischar(commandString)&&isequal(ndims(commandString),2)&&isequal(size(commandString,1),1)))
        MSLDiagnostic('Simulink:mpt:MPTInvalidInputArg',mfilename).reportAsWarning;
        return
    end


    UDDprop=get_rtw_hook_prop(hook);

    if isprop(hThisObj,UDDprop)
        hThisObj.(UDDprop)=commandString;
    else
        MSLDiagnostic('Simulink:mpt:MPTInvalidUserHook',hook,mfilename).reportAsWarning;
    end


    function UDDprop=get_rtw_hook_prop(hook)


        switch hook
        case 'entry'
            UDDprop='CodeGenEntry';
        case 'before_tlc'
            UDDprop='CodeGenBeforeTLC';
        case 'after_tlc'
            UDDprop='CodeGenAfterTLC';
        case 'before_make'
            UDDprop='CodeGenBeforeMake';
        case 'after_make'
            UDDprop='CodeGenAfterMake';
        case 'exit'
            UDDprop='CodeGenExit';
        otherwise
            UDDprop='';
        end
