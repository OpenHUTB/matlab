


classdef(ConstructOnLoad)RadixAbsEntry<RTW.TflCFunctionEntryML
    methods
        function obj=RadixAbsEntry(varargin)
            mlock;
            obj@RTW.TflCFunctionEntryML(varargin{:});
        end

        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong,...
            targetBitPerLongLong)%#ok











            ent=[];

            if length(hCSO.ConceptualArgs)~=2
                return;
            end
            outType=hCSO.ConceptualArgs(1).Type;
            in1Type=hCSO.ConceptualArgs(2).Type;

            if outType.Bias==0&&...
                in1Type.Bias==0&&...
                outType.SlopeAdjustmentFactor==in1Type.SlopeAdjustmentFactor

                a=-1.0*in1Type.FixedExponent;
                c=-1.0*outType.FixedExponent;

                wlin=in1Type.WordLength;
                wlout=outType.WordLength;

                if(((1-wlin)<=(c-a))&&((c-a)<=(wlout-1)))






                    ent=RTW.TflCFunctionEntry(hThis);
                    ent.SlopesMustBeTheSame=false;
                    ent.BiasMustBeTheSame=false;








                    for idx=1:2
                        ent.ConceptualArgs(idx).CheckSlope=true;
                        ent.ConceptualArgs(idx).CheckBias=true;


                        ent.ConceptualArgs(idx).Type=hCSO.ConceptualArgs(idx).Type;
                    end




                    ent.Implementation.Arguments(2).Value=a;
                    ent.Implementation.Arguments(3).Value=c;
                end
            end
        end
    end
end


