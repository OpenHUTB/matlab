


classdef(ConstructOnLoad)RadixAdditionEntry<RTW.TflCOperationEntryML
    methods
        function obj=RadixAdditionEntry(varargin)
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

                wl=outType.WordLength-1;

                validRange1=false;
                if((0<=abs(a-b))&&(abs(a-b)<=wl))
                    validRange1=true;
                end

                validRange2=false;
                if(a>=b)
                    if(((c-b)<=wl)&&((a-c)<=wl))
                        validRange2=true;
                    end
                else
                    if(((c-a)<=wl)&&((b-c)<=wl))
                        validRange2=true;
                    end
                end

                if validRange1&&validRange2






                    ent=RTW.TflCOperationEntry(hThis);








                    for idx=1:3
                        ent.ConceptualArgs(idx).CheckSlope=true;
                        ent.ConceptualArgs(idx).CheckBias=true;


                        ent.ConceptualArgs(idx).Type.Slope=hCSO.ConceptualArgs(idx).Type.Slope;
                        ent.ConceptualArgs(idx).Type.Bias=0;
                    end




                    if strcmp(ent.Implementation.Arguments(1).Name,'u1')
                        ent.Implementation.Arguments(3).Value=a;
                        ent.Implementation.Arguments(4).Value=b;
                    else

                        ent.Implementation.Arguments(3).Value=b;
                        ent.Implementation.Arguments(4).Value=a;
                    end
                    ent.Implementation.Arguments(5).Value=c;
                end
            end
        end
    end
end


