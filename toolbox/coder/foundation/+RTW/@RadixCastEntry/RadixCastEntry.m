


classdef(ConstructOnLoad)RadixCastEntry<RTW.TflCOperationEntryML
    methods
        function obj=RadixCastEntry(varargin)
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

            if length(hCSO.ConceptualArgs)==2&&...
                hCSO.ConceptualArgs(1).Type.Bias==0&&...
                hCSO.ConceptualArgs(2).Type.Bias==0&&...
                hCSO.ConceptualArgs(1).Type.SlopeAdjustmentFactor==1&&...
                hCSO.ConceptualArgs(2).Type.SlopeAdjustmentFactor==1

                a=-1.0*hCSO.ConceptualArgs(2).Type.FixedExponent;
                c=-1.0*hCSO.ConceptualArgs(1).Type.FixedExponent;

                wlin=hCSO.ConceptualArgs(2).Type.WordLength;
                wlout=hCSO.ConceptualArgs(1).Type.WordLength;

                if(a==c)&&(wlin<=wlout)


                    return
                end

                if(((1-wlin)<=(c-a))&&((c-a)<=(wlout-1)))






                    ent=RTW.TflCOperationEntry(hThis);








                    for idx=1:2
                        ent.ConceptualArgs(idx).CheckSlope=true;
                        ent.ConceptualArgs(idx).CheckBias=true;


                        ent.ConceptualArgs(idx).Type.Slope=hCSO.ConceptualArgs(idx).Type.Slope;
                        ent.ConceptualArgs(idx).Type.Bias=0;
                    end




                    ent.Implementation.Arguments(2).Value=a;
                    ent.Implementation.Arguments(3).Value=c;
                end
            end
        end
    end
end


