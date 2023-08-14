

function multiStr=convertCVV2String(cvv)



    isSimulinkVariantControl=Simulink.variant.manager.configutils.isScalarVariantControlObj(cvv);
    if isSimulinkVariantControl

        origcvv=cvv;
        cvv=cvv.Value;
    end

    multiStr=ii_cvvString(cvv(1));
    for ii=2:numel(cvv)
        multiStr=strcat(multiStr,', ',ii_cvvString(cvv(ii)));
    end

    if isSimulinkVariantControl



        multiStr=['Simulink.VariantControl(''Value'', ',multiStr,', ''ActivationTime'', ''',origcvv.ActivationTime,''')'];
    end

    function str=ii_cvvString(cvv)
        str='';

        cvvClass=class(cvv);
        cvvParamValue=Simulink.variant.reducer.utils.getCtrlVarValueBasedOnType(cvv);
        isEnum=Simulink.data.isSupportedEnumObject(cvvParamValue);
        cvvEnumClass=class(cvvParamValue);



        if isEnum

            strsCell=arrayfun(@(x)[cvvEnumClass,'.',char(x)],cvvParamValue,'UniformOutput',false);

            N=numel(strsCell);
            for ij=1:N-1
                str=strcat(str,strsCell{ij},', ');
            end
            str=strcat('[',str,strsCell{N},']');
            if~strcmp(cvvClass,cvvEnumClass)
                str=strcat(cvvClass,'(',str,')');
            end
        elseif isnumeric(cvv)

            str=Simulink.variant.reducer.utils.i_num2str(cvvParamValue);
        else

            cvvParamValueStr=Simulink.variant.reducer.utils.i_num2str(cvvParamValue);
            if numel(cvvParamValue)>1


                str=[cvvClass,'(','[',cvvParamValueStr,']',')'];
            else



                str=[cvvClass,'(',cvvParamValueStr,')'];
            end
        end
    end

end


