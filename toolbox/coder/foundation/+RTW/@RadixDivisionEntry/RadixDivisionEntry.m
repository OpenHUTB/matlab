


classdef(ConstructOnLoad)RadixDivisionEntry<RTW.TflCOperationEntryML
    methods
        function obj=RadixDivisionEntry(varargin)
            mlock;
            obj@RTW.TflCOperationEntryML(varargin{:});
        end

        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong,...
            targetBitPerLongLong)%#ok











            ent=[];

            if length(hCSO.ConceptualArgs)~=3
                return;
            end
            outType=hCSO.ConceptualArgs(1).Type;
            in1Type=hCSO.ConceptualArgs(2).Type;
            in2Type=hCSO.ConceptualArgs(3).Type;
            if outType.Bias==0&&...
                in1Type.Bias==0&&...
                in2Type.Bias==0&&...
                outType.SlopeAdjustmentFactor==1&&...
                in1Type.SlopeAdjustmentFactor==1&&...
                in2Type.SlopeAdjustmentFactor==1

                a=-1.0*in1Type.FixedExponent;
                b=-1.0*in2Type.FixedExponent;
                c=-1.0*outType.FixedExponent;

                netRadix=c+b-a;
                lowerLimit=-2*outType.WordLength+1;
                upperLimit=outType.WordLength-1;

                if lowerLimit<=netRadix&&netRadix<=upperLimit






                    ent=RTW.TflCOperationEntry(hThis);








                    for idx=1:3
                        ent.ConceptualArgs(idx).CheckSlope=true;
                        ent.ConceptualArgs(idx).CheckBias=true;


                        ent.ConceptualArgs(idx).Type.Slope=hCSO.ConceptualArgs(idx).Type.Slope;
                        ent.ConceptualArgs(idx).Type.Bias=0;
                    end




                    ent.Implementation.Arguments(3).Value=a;
                    ent.Implementation.Arguments(4).Value=b;
                    ent.Implementation.Arguments(5).Value=c;

                end
            end
        end
    end
end


