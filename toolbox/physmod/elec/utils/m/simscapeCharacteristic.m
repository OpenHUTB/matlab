classdef simscapeCharacteristic<handle



    properties(SetAccess=private,GetAccess=public)
curves
    end

    methods(Access=public)
        function theSimscapeCharacteristic=simscapeCharacteristic
            theSimscapeCharacteristic.curves={};
        end

        function addCurve(theSimscapeCharacteristic,curve)
            if~isa(curve,'simscapeCurve')
                pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeCharacteristic:error_InputArgumentMustBeASimscapeCurve')));
            end
            for ii=1:length(theSimscapeCharacteristic.curves)
                if theSimscapeCharacteristic.curves{ii}==curve
                    pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:simscapeCharacteristic:error_CurveAlreadyExistsInThisCharacteristic')));
                end
            end
            theSimscapeCharacteristic.curves{end+1}=curve;
        end

        function deleteCurve(theSimscapeCharacteristic,index)
            if index>length(theSimscapeCharacteristic.curves)
                pm_error('physmod:ee:library:NotFound',getString(message('physmod:ee:library:comments:utils:simscapeCharacteristic:error_CharacteristicCurveWithTheEvaluatedIndex')));
            end
            theSimscapeCharacteristic.curves(index)=[];
        end
    end
end