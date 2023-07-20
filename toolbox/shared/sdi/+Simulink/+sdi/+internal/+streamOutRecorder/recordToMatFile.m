

function recordToMatFile(model,domain,matVariableName,matFileName,fmt)

    data=Simulink.sdi.internal.getExportDataForStreamout(model,domain,fmt);
    if~isempty(data)

        assert(~isempty(matVariableName)&&ischar(matVariableName));

        assert(~isempty(matFileName)&&ischar(matFileName));
        [~,~,fext]=fileparts(matFileName);
        if~strcmpi(fext,'.mat')
            matFileName=[matFileName,'.mat'];
        end
        S.(sprintf(matVariableName,'%s'))=data;
        try
            save(matFileName,'-struct','S','-v7.3');
        catch
            error(message('Simulink:Logging:FileCreationError',matFileName));
        end
    end


end
