function tireParameters=tirread_common_private(filename)



















    filenameCell=matlab.io.internal.validators.validateFileName(filename);
    filename=filenameCell{1};


    [~,~,ext]=fileparts(filename);
    if~strcmpi(ext,".tir")
        error(message('physmod:sdl:utility:TirreadInvalidFileExtension'));
    end



    lines=readlines(filename);
    lines=erase(lines,{char(32),char(39)});



    for i=1:numel(lines)
        line=lines(i);
        line=removeComments(line,char(33));
        line=removeComments(line,char(36));
        lines(i)=line;
    end


    lines(strlength(lines)==0)=[];


    tireParameters=struct;

    for i=1:numel(lines)
        line=lines(i);

        if contains(line,char(91))


            section=line;
            section=erase(section,{char(91),char(93)});
        else



            if i==1
                error(message('physmod:sdl:utility:InvalidParameterDeclaration'));
            end



            nameValuePair=split(line,char(61));



            val=str2double(nameValuePair(2));


            if isnan(val)


                tireParameters.(section).(nameValuePair(1))=nameValuePair(2);
            else
                tireParameters.(section).(nameValuePair(1))=val;
            end

        end

    end

end


function line=removeComments(line,commentChar)





    if contains(line,commentChar)
        line=extractBefore(line,commentChar);
    end

end


