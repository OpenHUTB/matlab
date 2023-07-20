function schema






    package=findpackage('dspdialog');
    parent=findclass(package,'DSPDDG');

    this=schema.class(package,'CICDecimationObs',parent);


    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    if isempty(findtype('DSPCICDecimationFilterInternals'))
        schema.EnumType('DSPCICDecimationFilterInternals',...
        {'Full precision',...
        'Minimum section word lengths',...
        'Specify word lengths',...
        'Binary point scaling'});
    end


    schema.prop(this,'FilterSource','int');
    schema.prop(this,'mfiltObjectName','ustring');
    schema.prop(this,'DecimationFactor','ustring');
    schema.prop(this,'DifferentialDelay','ustring');
    schema.prop(this,'NumberOfSections','ustring');
    schema.prop(this,'FilterInternals','DSPCICDecimationFilterInternals');
    schema.prop(this,'SectionWordLengths','ustring');
    schema.prop(this,'SectionFracLengths','ustring');
    schema.prop(this,'OutputWordLength','ustring');
    schema.prop(this,'OutputFracLength','ustring');
    schema.prop(this,'RateOptions','DSPMultirateInhEnum');