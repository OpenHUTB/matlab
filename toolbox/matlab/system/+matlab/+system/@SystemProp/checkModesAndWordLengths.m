function checkModesAndWordLengths(obj,prefix)




    dataTypeProps=strcat(prefix,'DataType');
    firstMode=obj.(dataTypeProps{1});
    for ii=2:length(prefix)
        nextMode=obj.(dataTypeProps{ii});
        if~strcmp(firstMode,nextMode)

            props=dataTypeProps{1};
            for jj=2:length(prefix)
                props=[props,', ',dataTypeProps{jj}];%#ok<AGROW>
            end
            matlab.system.internal.error('MATLAB:system:mismatchedmodes',props);
        end
    end

    customDataTypeProps=strcat('Custom',dataTypeProps);
    if matlab.system.isSpecifiedTypeMode(firstMode)
        firstWL=obj.(customDataTypeProps{1}).WordLength;
        for ii=2:length(prefix)
            nextWL=obj.(customDataTypeProps{ii}).WordLength;
            if~isequal(firstWL,nextWL)

                props=customDataTypeProps{1};
                for jj=2:length(prefix)
                    props=[props,', ',customDataTypeProps{jj}];%#ok<AGROW>
                end
                matlab.system.internal.error('MATLAB:system:mismatchedwordlengths',props);
            end
        end
    end
end
