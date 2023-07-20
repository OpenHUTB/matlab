
classdef MinMaxHelper<handle






    methods(Static)











        function[mangle,...
            slMinNumeric,...
            slMaxNumeric]=shouldMangleAppTypeName(...
            m3iAppType,...
            embeddedObj,...
            modelName,slMin,slMax)

            narginchk(5,5);

            if isempty(m3iAppType)






                [slMinNumeric,...
                slMaxNumeric,...
                isMinEqualToTypeMin,...
                isMaxEqualToTypeMax]=...
                autosar.mm.util.MinMaxHelper.getSLMinMaxNumeric(...
                slMin,slMax,embeddedObj,modelName);
                mangle=~(isMinEqualToTypeMin&&isMaxEqualToTypeMax);
            else

                assert(m3iAppType.isvalid(),'m3iAppType is not valid!');




                [isEq,slMinNumeric,slMaxNumeric]=...
                autosar.mm.util.MinMaxHelper.isSLMinMaxEqualToM3iMinMax(...
                m3iAppType,slMin,slMax,modelName);
                mangle=~isEq;
            end
        end












        function[isEq,slMinNumeric,slMaxNumeric]=...
            isSLMinMaxEqualToM3iMinMax(m3iAppType,slMin,slMax,modelName)

            narginchk(4,4);
            assert(m3iAppType.isvalid(),'m3iAppType is not valid!');
            switch class(m3iAppType)
            case{'Simulink.metamodel.types.FixedPoint',...
                'Simulink.metamodel.types.Integer',...
                'Simulink.metamodel.types.Boolean'}

                [slMinNumeric,slMaxNumeric]=...
                autosar.mm.util.MinMaxHelper.resolveSLMinMaxToNumericValue(...
                slMin,slMax,m3iAppType,modelName);






                if(isempty(m3iAppType.minValue)||isinf(m3iAppType.minValue)&&...
                    isempty(m3iAppType.maxValue)||isinf(m3iAppType.maxValue))
                    m3iAppType.minValue=slMinNumeric;
                    m3iAppType.maxValue=slMaxNumeric;
                end

                areMinsEqual=~m3iAppType.isMinOpen&&~isempty(m3iAppType.minValue)&&...
                autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iAppType.minValue,slMinNumeric);

                areMaxsEqual=~m3iAppType.isMaxOpen&&~isempty(m3iAppType.maxValue)&&...
                autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iAppType.maxValue,slMaxNumeric);

                isEq=areMinsEqual&&areMaxsEqual;
            case 'Simulink.metamodel.types.FloatingPoint'

                [slMinNumeric,slMaxNumeric]=...
                autosar.mm.util.MinMaxHelper.resolveSLMinMaxToNumericValue(...
                slMin,slMax,m3iAppType,modelName);


                areMinsEqual=~isempty(m3iAppType.minValue)&&...
                autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iAppType.minValue,slMinNumeric);

                areMaxsEqual=...
                ~isempty(m3iAppType.maxValue)&&...
                autosar.mm.util.MinMaxHelper.tolerantIsEqual(m3iAppType.maxValue,slMaxNumeric);

                isEq=areMinsEqual&&areMaxsEqual;
            case 'Simulink.metamodel.types.Enumeration'

                isEq=false;
            otherwise
                assert(false,'Unexpected type "%s".',m3iAppType.qualifiedName);
            end
        end













        function[slMinNumeric,slMaxNumeric]=resolveSLMinMaxToNumericValue(...
            slMin,slMax,m3iAppType,modelName)

            narginchk(4,4);
            assert(m3iAppType.isvalid(),'m3iAppType is not valid!');

            switch class(m3iAppType)
            case 'Simulink.metamodel.types.Integer'
                [typeLowerVal,typeUpperVal]=autosar.utils.Math.toLowerAndUpperLimit(...
                m3iAppType.IsSigned,double(m3iAppType.Length.value));

                if isempty(slMin)||strcmp(slMin,'[]')
                    slMinNumeric=typeLowerVal;
                else
                    slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(...
                    slMin,modelName);
                end

                if isempty(slMax)||strcmp(slMax,'[]')
                    slMaxNumeric=typeUpperVal;
                else
                    slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(...
                    slMax,modelName);
                end
            case 'Simulink.metamodel.types.FixedPoint'
                f=fi(0,fixdt(m3iAppType.IsSigned,...
                double(m3iAppType.Length.value),...
                m3iAppType.slope,m3iAppType.Bias));
                typeLowerVal=double(f.lowerbound.data);
                typeUpperVal=double(f.upperbound.data);

                if isempty(slMin)||strcmp(slMin,'[]')
                    slMinNumeric=typeLowerVal;
                else
                    slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(...
                    slMin,modelName);
                end

                if isempty(slMax)||strcmp(slMax,'[]')
                    slMaxNumeric=typeUpperVal;
                else
                    slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(...
                    slMax,modelName);
                end
            case 'Simulink.metamodel.types.Boolean'
                typeLowerVal=0;
                typeUpperVal=1;

                if isempty(slMin)||strcmp(slMin,'[]')
                    slMinNumeric=typeLowerVal;
                else
                    slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMin,modelName);
                end

                if isempty(slMax)||strcmp(slMax,'[]')
                    slMaxNumeric=typeUpperVal;
                else
                    slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMax,modelName);
                end
            case 'Simulink.metamodel.types.FloatingPoint'
                typeLowerVal=-Inf;
                typeUpperVal=Inf;
                if isempty(slMin)||strcmp(slMin,'[]')
                    slMinNumeric=typeLowerVal;
                else
                    slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(...
                    slMin,modelName);
                end

                if isempty(slMax)||strcmp(slMax,'[]')
                    slMaxNumeric=typeUpperVal;
                else
                    slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMax,modelName);
                end
            otherwise
                assert(false,'Unexpected type "%s".',m3iAppType.qualifiedName);
            end
        end










        function[isSupported,minVal,maxVal]=getMinMaxValuesFromM3iType(m3iAppType,slTypeObj)
            narginchk(2,2);
            assert(m3iAppType.isvalid(),'m3iAppType is not valid!');
            isSupported=true;

            switch class(m3iAppType)
            case 'Simulink.metamodel.types.Matrix'


                [isSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(...
                m3iAppType.BaseType,slTypeObj);
            case{'Simulink.metamodel.types.LookupTableType','Simulink.metamodel.types.Axis'}


                [isSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(...
                m3iAppType.BaseType,slTypeObj);
            case 'Simulink.metamodel.types.SharedAxisType'


                [isSupported,minVal,maxVal]=...
                autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(...
                m3iAppType.Axis.BaseType,slTypeObj);
            case{'Simulink.metamodel.types.FixedPoint',...
                'Simulink.metamodel.types.Integer'}


                [typeLowerLimit,typeUpperLimit]=...
                autosar.utils.Math.toLowerAndUpperLimit(m3iAppType.IsSigned,...
                double(m3iAppType.Length.value));


                if isa(m3iAppType,'Simulink.metamodel.types.FixedPoint')
                    minValSI=(m3iAppType.minValue-m3iAppType.Bias)/m3iAppType.slope;
                    maxValSI=(m3iAppType.maxValue-m3iAppType.Bias)/m3iAppType.slope;
                else
                    minValSI=m3iAppType.minValue;
                    maxValSI=m3iAppType.maxValue;
                end

                if~m3iAppType.isMinOpen&&~m3iAppType.isMaxOpen
                    equalCheck=autosar.mm.util.MinMaxHelper.tolerantIsEqual(typeLowerLimit,minValSI)...
                    &&autosar.mm.util.MinMaxHelper.tolerantIsEqual(typeUpperLimit,maxValSI);
                    if equalCheck


                        minVal=[];
                        maxVal=[];
                    else


                        if(minValSI<typeLowerLimit)||isinf(m3iAppType.minValue)
                            minVal=[];
                        else
                            minVal=m3iAppType.minValue;
                        end

                        if(maxValSI>typeUpperLimit)||isinf(m3iAppType.maxValue)
                            maxVal=[];
                        else
                            maxVal=m3iAppType.maxValue;
                        end
                    end
                else

                    minVal=[];
                    maxVal=[];
                end




                if isa(m3iAppType,'Simulink.metamodel.types.FixedPoint')&&...
                    isa(slTypeObj,'Simulink.NumericType')
                    if~isempty(minVal)
                        minVal=double(fi(minVal,slTypeObj));
                    end

                    if~isempty(maxVal)
                        maxVal=double(fi(maxVal,slTypeObj));
                    end
                end

            case 'Simulink.metamodel.types.Boolean'
                if~m3iAppType.isMinOpen&&~m3iAppType.isMaxOpen
                    if((m3iAppType.minValue==0)&&(m3iAppType.maxValue==1))


                        minVal=[];
                        maxVal=[];
                    else


                        if isempty(intersect(m3iAppType.minValue,[0,1]))
                            minVal=[];
                        else
                            minVal=m3iAppType.minValue;
                        end

                        if isempty(intersect(m3iAppType.maxValue,[0,1]))
                            maxVal=[];
                        else
                            maxVal=m3iAppType.maxValue;
                        end
                    end
                else

                    minVal=[];
                    maxVal=[];
                end
            case 'Simulink.metamodel.types.FloatingPoint'
                minVal=[];
                maxVal=[];



                if~isinf(m3iAppType.minValue)
                    minVal=m3iAppType.minValue;
                end

                if~isinf(m3iAppType.maxValue)
                    maxVal=m3iAppType.maxValue;
                end




                if(m3iAppType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single)
                    if~isempty(minVal)
                        minVal=double(single(minVal));
                    end

                    if~isempty(maxVal)
                        maxVal=double(single(maxVal));
                    end
                end

            case 'Simulink.metamodel.types.Structure'



                minVal=[];
                maxVal=[];
            case 'Simulink.metamodel.types.Enumeration'


                isSupported=false;
                minVal=[];
                maxVal=[];
            otherwise
                assert(false,'Unexpected type "%s".',m3iAppType.qualifiedName);
            end
        end








        function[typeLowerVal,typeUpperVal]=getLowerUpperLimitsForNumericType(...
            embeddedObj,representation)

            narginchk(2,2);
            assert(embeddedObj.isNumeric,...
            'embeddedObj of numeric type is only supported');
            assert(any(strcmp(representation,{'StoredInteger','RealWorldValue'})),...
            'representation can only be StoredInteger or RealWorldValue');

            if embeddedObj.isDouble||embeddedObj.isSingle
                typeLowerVal=-Inf;
                typeUpperVal=Inf;
            else

                [typeLowerVal,typeUpperVal]=...
                autosar.utils.Math.toLowerAndUpperLimit(double(embeddedObj.Signedness),...
                double(embeddedObj.WordLength));
            end

            if strcmp(representation,'RealWorldValue')
                isFixedPoint=embeddedObj.isFixed&&(embeddedObj.Slope~=1||embeddedObj.Bias~=0);
                if isFixedPoint
                    f=fi(0,embeddedObj.Signedness,embeddedObj.WordLength,embeddedObj.Slope,embeddedObj.Bias);
                    typeLowerVal=double(f.lowerbound.data);
                    typeUpperVal=double(f.upperbound.data);
                end
            end
        end








        function value=getNumericValue(stringOrNum,modelName)
            narginchk(2,2);
            if ischar(stringOrNum)||isStringScalar(stringOrNum)
                value=slResolve(stringOrNum,modelName,'expression');
            else

                value=stringOrNum;
            end
        end








        function tolEqBool=tolerantIsEqual(valIn1,valIn2)
            assert(isscalar(valIn1),'valIn1 must be a scalar.');
            assert(isa(valIn1,'double'),'valIn1 must be a double.');
            assert(isscalar(valIn2),'valIn2 must be a scalar.');
            assert(isa(valIn2,'double'),'valIn2 must be a double.');


            if isequal(valIn1,valIn2)||(isinf(valIn1)&&isinf(valIn2))
                tolEqBool=true;
                return;
            end

            margin=sqrt(eps(min(abs(valIn1),abs(valIn2))));
            tolEqBool=false;
            error=abs(valIn1-valIn2);
            if error<=margin
                tolEqBool=true;
            end
        end
    end

    methods(Static,Access=private)




        function[slMinNumeric,...
            slMaxNumeric,...
            isMinEqualToTypeMin,...
            isMaxEqualToTypeMax]=getSLMinMaxNumeric(slMin,slMax,embeddedObj,modelName)

            [typeLowerVal,typeUpperVal]=...
            autosar.mm.util.MinMaxHelper.getLowerUpperLimitsForNumericType(...
            embeddedObj,'RealWorldValue');
            if isempty(slMin)||strcmp(slMin,'[]')
                slMinNumeric=typeLowerVal;
            else
                slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMin,modelName);
            end
            if isempty(slMax)||strcmp(slMax,'[]')
                slMaxNumeric=typeUpperVal;
            else
                slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slMax,modelName);
            end

            isMinEqualToTypeMin=autosar.mm.util.MinMaxHelper.tolerantIsEqual(slMinNumeric,typeLowerVal);
            isMaxEqualToTypeMax=autosar.mm.util.MinMaxHelper.tolerantIsEqual(slMaxNumeric,typeUpperVal);
        end
    end
end


