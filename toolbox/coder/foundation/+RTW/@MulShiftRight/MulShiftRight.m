


classdef(ConstructOnLoad)MulShiftRight<RTW.TflCOperationEntryML
    methods
        function obj=MulShiftRight(varargin)
            mlock;
            obj@RTW.TflCOperationEntryML(varargin{:});
        end

        function ent=do_match(hThis,...
            hCSO,...
            targetBitPerChar,...
            targetBitPerShort,...
            targetBitPerInt,...
            targetBitPerLong)%#ok











            ent=[];

            if length(hCSO.ConceptualArgs)~=3
                return
            end

            dty=hCSO.ConceptualArgs(1).Type;
            dtu1=hCSO.ConceptualArgs(2).Type;
            dtu2=hCSO.ConceptualArgs(3).Type;

            if dty.Bias==0&&...
                dtu1.Bias==0&&...
                dtu2.Bias==0


                net_saf=dtu1.SlopeAdjustmentFactor*...
                dtu2.SlopeAdjustmentFactor/...
                dty.SlopeAdjustmentFactor;

                a=dtu1.FixedExponent;
                b=dtu2.FixedExponent;
                c=dty.FixedExponent;

                shiftVal=c-a-b;

                if(net_saf==1)&&(shiftVal>0)






                    ent=RTW.TflCOperationEntry(hThis);








                    for idx=1:3
                        ent.ConceptualArgs(idx).CheckSlope=true;
                        ent.ConceptualArgs(idx).CheckBias=true;


                        ent.ConceptualArgs(idx).Type.DataTypeMode='Fixed-point: slope and bias scaling';
                        ent.ConceptualArgs(idx).Type.Slope=hCSO.ConceptualArgs(idx).Type.Slope;
                        ent.ConceptualArgs(idx).Type.Bias=0;
                    end
                    if length(ent.Implementation.Arguments)==3



                        ent.Implementation.Arguments(3).Value=shiftVal;
                    else
                        arg=RTW.TflArgNumericConstant('shift');
                        arg.Value=shiftVal;
                        ent.Implementation.addArgument(arg);
                    end
                end
            end
        end
    end
end

