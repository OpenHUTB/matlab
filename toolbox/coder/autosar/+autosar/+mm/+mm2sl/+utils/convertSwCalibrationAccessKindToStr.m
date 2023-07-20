function str=convertSwCalibrationAccessKindToStr(swCalAccessKind)




    import Simulink.metamodel.foundation.SwCalibrationAccessKind;
    if swCalAccessKind==SwCalibrationAccessKind.NotAccessible
        str='NotAccessible';
    elseif swCalAccessKind==SwCalibrationAccessKind.ReadOnly
        str='ReadOnly';
    elseif swCalAccessKind==SwCalibrationAccessKind.ReadWrite
        str='ReadWrite';
    else
        assert(false,'Did not recognize SwCalibrationAccessKind');
    end

end


