function h=SampleTargetCC(varargin)








    if nargin==0
        h=Simulink.SampleTargetCC('sample.tlc');
    elseif nargin==1&isa(varargin{1},'char')
        h=Simulink.SampleTargetCC(varargin{1});
    else
        h=[];
        error(DAStudio.message('RTW:configSet:ConfigSetSampleTargetCCError'));
    end





    set(h,'MakeCommand','make_rtw');
    set(h,'TemplateMakefile','grt_default_tmf');

