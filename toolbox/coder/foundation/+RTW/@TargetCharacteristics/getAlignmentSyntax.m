function syntax=getAlignmentSyntax(hThis,symbol,type,align,lang,aligntype)



    syntax='';

    da=hThis.DataAlignment;
    if isempty(da)
        DAStudio.error('CoderFoundation:tfl:UnableToAlignVariable',symbol,align,aligntype,lang);
    end
    len=length(da.AlignmentSpecifications);
    template=[];
    as=da.AlignmentSpecifications;
    for i=1:len
        aType=as(i).AlignmentType;
        supportedLangs=as(i).SupportedLanguages;
        if~isempty(find(strcmp(aType,aligntype),1))&&...
            ~isempty(find(strcmp(supportedLangs,lang),1))
            template=as(i).AlignmentSyntaxTemplate;
            break;
        end
    end

    if~isempty(template)
        syntax=regexprep(template,'%s',symbol);
        syntax=regexprep(syntax,'%t',type);
        syntax=regexprep(syntax,'%n',num2str(align));
    else
        DAStudio.error('CoderFoundation:tfl:UnableToAlignVariable',symbol,align,aligntype,lang);
    end

end
