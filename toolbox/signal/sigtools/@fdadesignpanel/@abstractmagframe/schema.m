function schema

    pk=findpackage('fdadesignpanel');
    c=schema.class(pk,'abstractmagframe',pk.findclass('abstractfiltertype'));
    c.Description='abstract';

    if isempty(findtype('fdadesignpanelIRType'))
        schema.EnumType('fdadesignpanelIRType',{'IIR','FIR'});
    end

    if isempty(findtype('fdadesignpanelMagUnits'))
        schema.EnumType('fdadesignpanelMagUnits',{'dB','Linear','Squared'});
    end
    p=schema.prop(c,'IRType','fdadesignpanelIRType');
    p.SetFunction=@setirtype;
    p.Description='spec';
    p=schema.prop(c,'magUnits','fdadesignpanelMagUnits');
    p.SetFunction=@setmagunits;
    p.FactoryValue='dB';
    p.Description='spec';


    function out=setirtype(h,out)
        set(h,'MagUnits','dB');


        function out=setmagunits(h,out)

            switch h.IRType
            case 'IIR'
                if isempty(find(strcmpi(out,{'db','squared'}),1))
                    error(message('signal:fdadesignpanel:abstractmagframe:schema:invalidMagUnitsIIR',out,'magUnits'));
                end
            case 'FIR'
                if isempty(find(strcmpi(out,{'db','linear'}),1))
                    error(message('signal:fdadesignpanel:abstractmagframe:schema:invalidMagUnitsFIR',out,'magUnits'));
                end
            end


