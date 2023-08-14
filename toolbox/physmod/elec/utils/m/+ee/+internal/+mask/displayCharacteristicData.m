function[output_string,output_data]=displayCharacteristicData(ds)



    if~isa(ds,'simscapeBlockDataset')
        pm_error('physmod:ee:library:MaskParameterOverride',getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:error_InputArgumentMustBeASimscapeBlockDataset')));
    end

    numberOfCharacteristics=length(ds.characteristicData);

    output_string=[sprintf(getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:sprintf_CharacteristicData',ds.name))),'\n'];
    output_data.name=ds.name;
    if numberOfCharacteristics<=0
        output_string=[output_string,'\t',getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:sprintf_NoCharacteristicDataFound')),'\n'];
        output_data.characteristics={};
    else
        output_data.characteristics=cell(1,numberOfCharacteristics);
        for ii=1:numberOfCharacteristics
            output_string=[output_string,'\t',sprintf(getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:sprintf_Characteristic',ii))),'\n'];%#ok<*AGROW>
            numberOfCurves=length(ds.characteristicData(ii).curves);
            if numberOfCurves<=0
                output_string=[output_string,'\t\t',getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:sprintf_NoCurvesFound')),'\n'];
                output_data.characteristics{ii}={};
            else
                output_data.characteristics{ii}=cell(1,numberOfCurves);
                for jj=1:numberOfCurves
                    curveLabel=ee.internal.mask.getCurveType(ds.characteristicData(ii).curves{jj});
                    output_string=[output_string,'\t\t',getString(message('physmod:ee:library:comments:utils:mask:displayCharacteristicData:sprintf_Curve',num2str(jj),curveLabel))];
                    output_string=[output_string,'\n'];
                    output_data.characteristics{ii}{jj}=curveLabel;
                end
            end
        end
        output_string=[output_string,'\n'];
    end
end