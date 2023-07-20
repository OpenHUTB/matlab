






classdef InsertedBlockType<uint8

    enumeration
        TERMINATOR(0);
        GROUND(1);
        SIGNALSPECIFICATION(2);
        CONSTANT(3);
        LABEL_MODE_SISO_VARIANT_SOURCE(4);
        BUS_SUBSYSTEM(5);
        BUS_SUBSYSTEM_CONSTANT(6);
        BUS_SUBSYSTEM_SIGNAL_CONVERSION(7);
        BUS_SUBSYSTEM_OUTPORT(8);
    end

    methods


        function[blkPath,blkTag]=getBlockPath(obj)
            switch obj
            case Simulink.variant.reducer.InsertedBlockType.TERMINATOR
                blkPath='built-in/Terminator';
                blkTag='VariantReducer_Terminator';
            case Simulink.variant.reducer.InsertedBlockType.GROUND
                blkPath='built-in/Ground';
                blkTag='VariantReducer_Ground';
            case Simulink.variant.reducer.InsertedBlockType.SIGNALSPECIFICATION
                blkPath='simulink/Signal Attributes/Signal Specification';
                blkTag='VariantReducer_SignalSpecification';
            case Simulink.variant.reducer.InsertedBlockType.CONSTANT
                blkPath='built-in/Constant';
                blkTag='VariantReducer_Constant';
            case Simulink.variant.reducer.InsertedBlockType.LABEL_MODE_SISO_VARIANT_SOURCE
                blkPath=['simulink/Signal',newline,'Routing/Variant',newline,'Source'];
                blkTag='VariantReducer_LabelModeSISOVariantSource';
            case Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM
                blkPath=['simulink/Ports &',newline,'Subsystems/Subsystem'];
                blkTag='VariantReducer_BusObject';
            case Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_CONSTANT
                blkPath='built-in/Constant';
                blkTag='VariantReducer_BusObject';
            case Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_SIGNAL_CONVERSION
                blkPath=['simulink/Signal',newline,'Attributes/Signal',newline,'Conversion'];
                blkTag='VariantReducer_BusObject';
            case Simulink.variant.reducer.InsertedBlockType.BUS_SUBSYSTEM_OUTPORT
                blkPath=['simulink/Ports &',newline,'Subsystems/Out1'];
                blkTag='VariantReducer_BusObject';
            otherwise
                Simulink.variant.reducer.utils.assert(true,'Invalid block type to be added');
            end
        end
    end
end
