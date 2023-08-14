classdef DataType<handle
    methods(Static,Access=public)
        function dtaItems=l_getDTCapabilitiesOfInport
            dtaItems=struct;
            dtaItems.inheritRules='Inherit: auto';
            dtaItems.builtinTypes={'double','single','int8','uint8','int16','uint16','int32','uint32','boolean'};
            dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode','UDTBestPrecisionMode'};
            dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};
            dtaItems.supportsEnumType=true;
            dtaItems.supportsBusType=true;
        end



        function resolved=l_dtPrmResolved(dtPrmValue,inportH)
            dtCapabilities=coder.internal.DataType.l_getDTCapabilitiesOfInport;
            res=Simulink.DataTypePrmWidget.parseDataTypeString(dtPrmValue,dtCapabilities);
            resolved=false;
            exprToResolve=[];
            if res.isInherit||res.isBuiltin
                resolved=true;
            elseif res.isFixPt||res.isExpress
                exprToResolve=dtPrmValue;
            elseif res.isBusType
                exprToResolve=res.busObjectName;
            elseif res.isEnumType
                exprToResolve=['?',res.enumClassName];
            else
                assert(false,'Data type parameters cannot be resolved');
            end
            if~resolved
                [~,resolved]=slResolve(exprToResolve,inportH);
            end
        end
    end
end
