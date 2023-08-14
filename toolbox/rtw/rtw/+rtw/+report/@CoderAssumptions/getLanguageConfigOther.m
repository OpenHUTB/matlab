function out=getLanguageConfigOther(obj,assumptions,useHost)




    if useHost
        hardwareProps=assumptions.Assumptions.PortableWordSizesHardware;
    else
        hardwareProps=assumptions.Assumptions.TargetHardware;
    end


    isShiftRight=obj.logicalToTFString(hardwareProps.ShiftRightIntArith);

    out={DAStudio.message('RTW:report:CoderAssumptionsEndianess'),char(hardwareProps.Endianess);...
    DAStudio.message('RTW:report:CoderAssumptionsShiftRightInt'),isShiftRight;...
    DAStudio.message('RTW:report:CoderAssumptionsSigIntDivRounds'),char(hardwareProps.IntDivRoundTo);...
    };

end
