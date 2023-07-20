function writeCreateCellToFile(fileID,createCommentText,varCellName,simStruct,fieldName,STRREP_CHAR)




    fprintf(fileID,'%% %s \n',createCommentText);
    fprintf(fileID,'%s = { ...\n',varCellName);

    for k=1:length(simStruct)

        if~STRREP_CHAR
            fprintf(fileID,'''%s'' , ...\n',simStruct(k).(fieldName));
        else
            fprintf(fileID,'''%s'' , ...\n',strrep(simStruct(k).(fieldName),'''',''''''));
        end

        if k==length(simStruct)
            fprintf(fileID,'}; \n');
        end

    end


end

