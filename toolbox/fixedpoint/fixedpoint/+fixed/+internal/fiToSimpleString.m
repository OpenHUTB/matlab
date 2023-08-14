function stringRepresentation=fiToSimpleString(value,extraPretty)
































    validateattributes(value,{'embedded.fi'},{});

    if nargin<2
        extraPretty=false;
    end

    nt=fixed.extractNumericType(value);

    if isSupported(value,nt,extraPretty)

        vDbl=double(value);
        if isscalar(vDbl)
            vDblStr=fixed.internal.compactButAccurateNum2Str(vDbl);
        else
            vDblStr=fixed.internal.compactButAccurateMat2Str(vDbl);
        end

        if isfixed(value)
            if nt.isslopebiasscaled
                if~fixed.internal.type.slopeFitsInDouble(nt)
                    stringRepresentation=sprintf(...
                    "fi(%s,%d,%d,%s,%d,%s)",...
                    vDblStr,...
                    nt.SignednessBool,...
                    nt.WordLength,...
                    fixed.internal.compactButAccurateNum2Str(nt.SlopeAdjustmentFactor),...
                    nt.FixedExponent,...
                    fixed.internal.compactButAccurateNum2Str(nt.Bias)...
                    );
                else
                    stringRepresentation=sprintf(...
                    "fi(%s,%d,%d,%s,%s)",...
                    vDblStr,...
                    nt.SignednessBool,...
                    nt.WordLength,...
                    fixed.internal.compactButAccurateNum2Str(nt.Slope),...
                    fixed.internal.compactButAccurateNum2Str(nt.Bias)...
                    );
                end
            else
                stringRepresentation=sprintf(...
                "fi(%s,%d,%d,%d)",...
                vDblStr,...
                nt.SignednessBool,...
                nt.WordLength,...
                -nt.FixedExponent...
                );
            end
        else
            stringRepresentation=sprintf(...
            "fi(%s,%s)",...
            vDblStr,...
            nt.tostring...
            );
        end
    else
        stringRepresentation='';
    end
end

function b=isSupported(value,nt,extraPretty)

    is2D=numel(size(value))<=2;

    if~is2D
        b=false;

    elseif fixed.internal.type.isTypeSuperset('double',nt)

        b=true;

    elseif~extraPretty||~isfixed(value)

        b=false;

    else

        v2=fixed.internal.math.fullSlopeBiasToBinPt(value);
        ntTight=fixed.internal.type.tightFixedPointType(v2,2^16);
        b=fixed.internal.type.isTypeSuperset('double',ntTight);
    end
end

