function schema




    pk=findpackage('siggui');
    pk.findclass('fsspecifier');
    pk.findclass('coeffspecifier');


    c=schema.class(pk,'import',pk.findclass('sigcontainer'));




    p=schema.prop(c,'isImported','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';

    e=schema.event(c,'FilterGenerated');


    if isempty(findtype('FDAToolInputProcesingTypes'))
        schema.EnumType('FDAToolInputProcesingTypes',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end

    p=schema.prop(c,'InputProcessing','FDAToolInputProcesingTypes');
    set(p,'FactoryValue','Columns as channels (frame based)');



