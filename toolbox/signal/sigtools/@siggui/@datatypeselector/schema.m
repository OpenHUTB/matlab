function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'datatypeselector',pk.findclass('sigcontainer'));

    if isempty(findtype('signalCDataType'))
        schema.EnumType('signalCDataType',...
        {'int32','int16','int8','uint32','uint16','uint8','double','single'});
    end
    if isempty(findtype('datatypeselections'))
        schema.EnumType('datatypeselections',...
        {'suggested','exportas'});
    end

    schema.prop(c,'Selection','datatypeselections');

    p=schema.prop(c,'ExportType','signalCDataType');
    set(p,'SetFunction',@setexporttype);

    p=schema.prop(c,'FractionalLength','mxArray');
    set(p,'FactoryValue',15);

    schema.prop(c,'SuggestedType','signalCDataType');

    p=schema.prop(c,'Listeners','handle vector');
    p.AccessFlag.PublicSet='Off';
    p.AccessFlag.PublicGet='Off';

    e=schema.event(c,'NewDataType');


    function extype=setexporttype(this,extype)

        set(this,'Selection','exportas');


