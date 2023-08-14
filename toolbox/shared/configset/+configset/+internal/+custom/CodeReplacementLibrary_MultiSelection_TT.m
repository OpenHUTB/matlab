function tt=CodeReplacementLibrary_MultiSelection_TT(cs,~)

    tr=RTW.TargetRegistry.get;
    lineBreaker='\n';

    if isa(cs,'Simulink.ConfigSet')
        hSrc=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hSrc=cs.getComponent('Target');
    else
        hSrc=cs;
    end

    currentCRL=coder.internal.getCrlLibraries(hSrc.CodeReplacementLibrary);
    len=length(currentCRL);
    tt=[DAStudio.message('RTW:configSet:customCodeReplacementLibraryTextTooltip'),lineBreaker,lineBreaker];
    for i=1:len
        tt=sprintf([tt,currentCRL{i},lineBreaker]);
    end
