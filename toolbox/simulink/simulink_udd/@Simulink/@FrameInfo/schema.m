function schema





    p=findpackage('Simulink');
    c=schema.class(p,'FrameInfo',findclass(p,'TimeInfo'));


    if isempty(findtype('FrameState'))
        schema.EnumType('FrameState',{'Samples','Frames'});
    end


    p=schema.prop(c,'State','FrameState');
    p.FactoryValue='Samples';
    schema.prop(c,'Framesize','double');
    schema.prop(c,'FrameStart','MATLAB array');
    schema.prop(c,'FrameEnd','MATLAB array');
    schema.prop(c,'FrameIncrement','double');



