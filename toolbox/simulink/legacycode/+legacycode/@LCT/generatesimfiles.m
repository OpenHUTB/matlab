function generatesimfiles(h)









    if nargin<1
        DAStudio.error('Simulink:tools:LCTErrorFirstFcnArgumentMustBeStruct');
    end


    h=h(:);

    for ii=1:length(h)
        h(ii).generatesfcn;
        h(ii).compile;
        if h(ii).Options.useTlcWithAccel
            h(ii).generatetlc;
        end
    end


