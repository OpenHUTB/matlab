function[rinterface,winterface]=getCharacteristicInterfaceFactory(attributes)





    rinterface=matlabshared.blelib.read.characteristic.Default;
    winterface=matlabshared.blelib.write.characteristic.Default;

    for attribute=attributes
        switch attribute
        case{"Write","WriteWithoutResponse","AuthenticatedSignedWrites","ReliableWrites"}
            winterface=matlabshared.blelib.write.characteristic.WriteCommon;

        case "Read"
            if isa(rinterface,'matlabshared.blelib.read.characteristic.Default')
                rinterface=matlabshared.blelib.read.characteristic.ReadOnly;
            elseif isa(rinterface,'matlabshared.blelib.read.characteristic.NotifyOnly')
                rinterface=matlabshared.blelib.read.characteristic.ReadNotify;
            end

        case{"Notify","Indicate","NotifyEncryptionRequired","IndicateEncryptionRequired"}
            if isa(rinterface,'matlabshared.blelib.read.characteristic.Default')
                rinterface=matlabshared.blelib.read.characteristic.NotifyOnly;
            elseif isa(rinterface,'matlabshared.blelib.read.characteristic.ReadOnly')
                rinterface=matlabshared.blelib.read.characteristic.ReadNotify;
            end

        otherwise


        end
    end
end