function validateCoefDataType(blkName,coeffDTChek,inputDT,coeff,coeffDT,precisionCheck,zeroCoeffCheck,isMATLABSystemBlock)




    coder.extrinsic('gcb','get_param','bdroot');
    if coeffDTChek
        if zeroCoeffCheck
            if isfloat(numerictype(inputDT))
                post_cast=coeff;
            elseif isnumerictype(coeffDT)
                post_cast=cast(coeff,'like',fi(0,coeffDT));
            else
                post_cast=coeff;
            end
            if all(post_cast==0)
                coder.internal.error('dsphdl:FIRFilter:AllZeroCoeffs',blkName);
            end

        end
        if precisionCheck&&isnumerictype(coeffDT)
            if~coeffDT.isscalingunspecified
                if any(coeff(:)<0)
                    expectedCast=fi(coeff,1,coeffDT.WordLength);
                    expectedFRL=expectedCast.FractionLength;
                else
                    expectedCast=fi(coeff,0,coeffDT.WordLength);
                    expectedFRL=expectedCast.FractionLength;
                end
            end

            if~isMATLABSystemBlock

                if any(coeff(:)<0)&&~coeffDT.SignednessBool
                    coder.internal.warning('dsphdl:FIRFilter:UnexpectedCoefficientsDataType',blkName);
                end
                if~coeffDT.isscalingunspecified
                    if coeffDT.FractionLength<expectedFRL
                        coder.internal.warning('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength',blkName)
                    end
                end
            else
                paramValue=coder.const(get_param(bdroot,'FixptConstPrecisionLossMsg'));
                if strcmpi(paramValue,'error')

                    if any(coeff(:)<0)&&~coeffDT.SignednessBool
                        coder.internal.error('dsphdl:FIRFilter:UnexpectedCoefficientsDataType',blkName);
                    end
                    if~coeffDT.isscalingunspecified
                        if coeffDT.FractionLength<expectedFRL
                            coder.internal.error('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength',blkName);
                        end
                    end
                elseif strcmpi(paramValue,'warning')

                    if any(coeff(:)<0)&&~coeffDT.SignednessBool
                        coder.internal.warning('dsphdl:FIRFilter:UnexpectedCoefficientsDataType',blkName);
                    end
                    if~coeffDT.isscalingunspecified
                        if coeffDT.FractionLength<expectedFRL
                            coder.internal.warning('dsphdl:FIRFilter:UnsufficientCoefficientsFractionalLength',blkName);
                        end
                    end
                end
            end
        end
    end
end
