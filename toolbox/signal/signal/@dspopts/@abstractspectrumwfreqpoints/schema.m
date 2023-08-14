function schema





    pk=findpackage('dspopts');
    c=schema.class(pk,'abstractspectrumwfreqpoints',...
    pk.findclass('abstractspectrum'));
    set(c,'Description','abstract');

    if isempty(findtype('psdFreqPointsType'))
        schema.EnumType('psdFreqPointsType',{'All','User Defined'});
    end

    p=schema.prop(c,'FreqPoints','psdFreqPointsType');
    p.FactoryValue='All';
    p.AccessFlags.AbortSet='off';
    p.SetFunction=@set_freqpoints;


