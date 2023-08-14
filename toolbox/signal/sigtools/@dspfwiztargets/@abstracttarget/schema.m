function schema




    pk=findpackage('dspfwiztargets');
    c=schema.class(pk,'abstracttarget');
    c.Description='Abstract';



    definetypes;


    p=schema.prop(c,'Destination','ustring');
    p.Factoryvalue='Current';
    schema.prop(c,'Blockname','ustring');
    schema.prop(c,'OverwriteBlock','on/off');

    p=schema.prop(c,'IsInputProcessingSpecified','bool');
    p.FactoryValue=false;
    p=schema.prop(c,'IsRateOptionSpecified','bool');
    p.FactoryValue=false;

    schema.prop(c,'InputProcessing','FDDlgInputProcessing');
    schema.prop(c,'RateOption','FDDlgRateOption');


    p=schema.prop(c,'system','ustring');
    p.AccessFlags.PublicSet='off';
    p.Visible='off';

    function definetypes



        if isempty(findtype('FDDlgInputProcessing'))
            schema.EnumType('FDDlgInputProcessing',{'columnsaschannels',...
            'elementsaschannels',...
            'inherited'});
        end

        if isempty(findtype('FDDlgRateOption'))
            schema.EnumType('FDDlgRateOption',{'enforcesinglerate',...
            'allowmultirate'});
        end
