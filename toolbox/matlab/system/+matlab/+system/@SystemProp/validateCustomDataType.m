function validateCustomDataType(obj,prop,type,res)



























    if iscellstr(res)&&isequal(numel(res),2)&&strcmp(res{1},'Property')
        dataTypeSet=obj.(res{2});
        dataTypeSet.validateCustomDataType(prop,type);
        return;
    end


    if~isa(type,'embedded.numerictype')
        matlab.system.internal.error('MATLAB:system:numerictypeNotSpecified',prop);
    end

    if any(strcmp(res,'ALLOWFLOAT'))
        if~any(strcmp(type.DataType,{'Fixed','double','single'}))
            matlab.system.internal.error('MATLAB:system:invalidNumericTypeDataType',prop);
        end
    else
        if~strcmp(type.DataType,'Fixed')
            matlab.system.internal.error('MATLAB:system:mustBeFixedPointNumericType',prop);
        end
    end


    if strcmp(type.DataType,'Fixed')
        if~isequal(type.SlopeAdjustmentFactor,1.0)||~isequal(type.Bias,0.0)
            matlab.system.internal.error('MATLAB:system:invalidNumericTypeSlopeBias',prop);
        end


        if any(strcmp(res,'SIGNED'))

            if~strcmp(type.Signedness,'Signed')
                matlab.system.internal.error('MATLAB:system:mustBeSignedNumericType',prop);
            end
        end
        if any(strcmp(res,'UNSIGNED'))

            if~strcmp(type.Signedness,'Unsigned')
                matlab.system.internal.error('MATLAB:system:mustBeUnsignedNumericType',prop);
            end
        end
        if any(strcmp(res,'AUTOSIGNED'))||any(strcmp(res,'NOTSIGNED'))


            if~strcmp(type.Signedness,'Auto')
                matlab.system.internal.error('MATLAB:system:mustBeAutoSignedNumericType',prop);
            end
        end
        if any(strcmp(res,'SPECSIGNED'))

            if strcmp(type.Signedness,'Auto')
                matlab.system.internal.error('MATLAB:system:mustBeSpecSignedNumericType',prop);
            end
        end
        if any(strcmp(res,'SIGNEDORAUTOSIGNED'))

            if strcmp(type.Signedness,'Unsigned')
                matlab.system.internal.error('MATLAB:system:mustBeSignedOrAutoSignedNumericType',prop);
            end
        end


        if any(strcmp(res,'SCALED'))

            if~strcmp(type.Scaling,'BinaryPoint')&&~strcmp(type.Scaling,'SlopeBias')
                matlab.system.internal.error('MATLAB:system:mustBeScaledNumericType',prop);
            end
        end
        if any(strcmp(res,'NOTSCALED'))

            if~strcmp(type.Scaling,'Unspecified')
                matlab.system.internal.error('MATLAB:system:mustBeNotScaledNumericType',prop);
            end
        end
    end
end
