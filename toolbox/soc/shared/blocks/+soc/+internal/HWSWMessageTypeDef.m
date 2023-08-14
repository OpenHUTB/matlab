function HWSWMessageTypeDef()




    evalin('base','rteStartup');

    soc.internal.registerSoCData;

    if~(exist('HWSWMetadataID','class')==8)
        Simulink.defineIntEnumType(...
        'HWSWMetadataID',...
        {'Unknown','UDP','TCP','Register','Stream','Memory','Custom',...
        },...
        (0:6),...
        'Description','Enum for HW/SW Message ID');
    end







end


