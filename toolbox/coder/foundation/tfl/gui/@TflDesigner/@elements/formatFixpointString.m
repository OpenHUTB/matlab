function type=formatFixpointString(~,dttype)




    if isempty(strfind(dttype,'fix'))
        type=dttype;
    else
        dtype=dttype(strfind(dttype,'(')+1:strfind(dttype,')')-1);

        [signbit,r]=strtok(dtype,',');
        signbit=logical(eval(signbit));
        wordLength=strtok(r,',');

        allowableLengths={'8','16','32','64'};

        if isempty(find(strcmp(allowableLengths,wordLength),1))
            wordLength='32';
        end

        if signbit
            type=strcat('int',wordLength);
        else
            type=strcat('uint',wordLength);
        end

        type=strcat(dttype(1:strfind(dttype,'fix')-1),type);
        type=strcat(type,dttype((strfind(dttype,')')+1):end));
    end
