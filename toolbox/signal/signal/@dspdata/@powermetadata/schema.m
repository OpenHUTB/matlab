function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'powermetadata');


    schema.prop(c,'DataUnits','string');

    p=schema.prop(c,'FrequencyUnits','string');
    set(p,'setFunction',@setfrequencyunits);
    p.FactoryValue='Hz';

    p=schema.prop(c,'SourceSpectrum','mxArray');
    set(p,'setFunction',@checkclasstype);
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    function frequnits=setfrequencyunits(this,frequnits)

        if isempty(frequnits)
            frequnits=this.Metadata.FrequencyUnits;
            error(message('signal:dspdata:powermetadata:schema:invalidFrequencyUnits'));
        end



        function value=checkclasstype(this,value)

            if~isempty(value)&&~isa(value,'spectrum.abstractspectrum')
                error(message('signal:dspdata:powermetadata:schema:InvalidClass'));
            end




