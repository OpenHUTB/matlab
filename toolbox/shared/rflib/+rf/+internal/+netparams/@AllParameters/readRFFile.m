function fileobj=readRFFile(obj,filename)


    [~,~,ext]=fileparts(filename);
    switch ext
    case{'.s2d','.p2d','.amp'}

        error(message('rflib:shared:ReadRFFileExtNotSupported',ext,class(obj)))
    otherwise

        if isempty(ext)

            warning(message('rflib:shared:ReadRFFileMissingExt',filename))
        elseif length(ext)<4||lower(ext(end))~='p'||...
            ~any(strcmpi(ext(2),{'s','y','z','h','g'}))||...
            isnan(str2double(ext(3:(end-1))))

            warning(message('rflib:shared:ReadRFFileUnknownExt',ext))
        end
        fileobj=rf.file.touchstone.Data(filename);
    end