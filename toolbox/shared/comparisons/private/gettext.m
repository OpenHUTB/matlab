function[text,readable]=gettext(source)












    if ischar(source)||(isstring(source)&&isscalar(source))

        source=char(source);
        [text,readable]=i_ReadFromFile(source);
        return
    end

    assert(isa(source,'com.mathworks.comparisons.source.ComparisonSource'),...
    'Inputs to textdiff must be file names or ComparisonSources');
    absnameprop=com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    textprop=com.mathworks.comparisons.source.property.CSPropertyText.getInstance();
    readableprop=com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();



    if source.hasProperty(textprop)
        readable=[];


        text=char(source.getPropertyValue(textprop,[]));
        if~isempty(text)
            text=i_textscan(text);
            if source.hasProperty(absnameprop)
                readable=char(source.getPropertyValue(absnameprop,[]));
            end
        end
    elseif source.hasProperty(readableprop)

        try
            readable=char(source.getPropertyValue(readableprop,[]));
        catch E %#ok<NASGU>
            if source.hasProperty(absnameprop)
                filename=char(source.getPropertyValue(absnameprop,[]));
            else
                nameprop=com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
                filename=char(source.getPropertyValue(nameprop,[]));
            end
            comparisons.internal.message('error','comparisons:comparisons:FileReadError',filename)
        end
        [text,readable]=i_ReadFromFile(readable);
    elseif source.hasProperty(absnameprop)


        absname=char(source.getPropertyValue(absnameprop,[]));
        [text,readable]=i_ReadFromFile(absname);
    end
end


function[text,filename]=i_ReadFromFile(filename)
    filename=comparisons.internal.resolvePath(filename);
    d=dir(filename);
    if numel(d)~=1&&exist(filename,'dir')~=0



        comparisons.internal.message('error','comparisons:comparisons:FolderNotAllowed');
    else


        text=i_GetTextFromFile(filename);
    end
end


function txt=i_GetTextFromFile(filename)







    is=java.io.FileInputStream(java.io.File(filename));
    enc=com.mathworks.xml.EncodingParser.getEncoding(is);
    is.close();

    fid=fopen(filename,'r','native',char(enc));
    if fid<0
        comparisons.internal.message('error','comparisons:comparisons:FileReadError',filename)
    end


    try
        data=fread(fid,'*char')';
        txt=i_textscan(data);
        fclose(fid);
    catch exception
        fclose(fid);
        rethrow(exception)
    end
end


function txt=i_textscan(data)

    data=strrep(data,[char(13),newline],newline);

    data=strrep(data,char(13),newline);



    txt=regexp(data,newline,'split');
    txt=txt';
end
