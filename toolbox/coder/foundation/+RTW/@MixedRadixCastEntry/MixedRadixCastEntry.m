


classdef(ConstructOnLoad)MixedRadixCastEntry<RTW.TflCOperationEntryML
    methods
        function obj=MixedRadixCastEntry(varargin)
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

            if length(hCSO.ConceptualArgs)==2
                outT=hCSO.ConceptualArgs(1).Type;
                inT=hCSO.ConceptualArgs(2).Type;
                if outT.issingle&&inT.isfixed
                    if inT.Bias==0&&inT.SlopeAdjustmentFactor==1.0
                        a=-1.0*inT.FixedExponent;

                        ent=RTW.TflCOperationEntry(hThis);
                        ent.ConceptualArgs(1).CheckSlope=true;
                        ent.ConceptualArgs(2).CheckSlope=true;
                        ent.ConceptualArgs(1).CheckBias=true;
                        ent.ConceptualArgs(2).CheckBias=true;
                        ent.ConceptualArgs(2).Type.Slope=inT.Slope;
                        ent.ConceptualArgs(2).Type.Bias=0;




                        ent.Implementation.Arguments(2).Value=a;
                    end
                elseif inT.issingle&&outT.isfixed
                    if outT.Bias==0&&outT.SlopeAdjustmentFactor==1.0
                        a=-1.0*outT.FixedExponent;

                        ent=RTW.TflCOperationEntry(hThis);
                        ent.ConceptualArgs(2).CheckSlope=true;
                        ent.ConceptualArgs(1).CheckSlope=true;
                        ent.ConceptualArgs(2).CheckBias=true;
                        ent.ConceptualArgs(1).CheckBias=true;
                        ent.ConceptualArgs(1).Type.Slope=inT.Slope;
                        ent.ConceptualArgs(1).Type.Bias=0;




                        ent.Implementation.Arguments(2).Value=a;
                    end
                end
            end
        end
    end
end
