function fixAttributesFormatString(blockH)




    str=get_param(blockH,'AttributesFormatString');
    [head,tail]=strtok(str,'%<');
    while~isempty(head)
        index=strfind(head,'>');
        if length(index)==1
            varName=head(1:index-1);
            try
                get_param(blockH,varName);
            catch Mex %#ok<NASGU>
                repStr=['%<',varName,'>'];
                str=strrep(str,repStr,'');
            end
        end
        [head,tail]=strtok(tail,'%<');%#ok<STTOK>
    end
    set_param(blockH,'AttributesFormatString',str);
end

