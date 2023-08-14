function pValue=getAnnotationMarkup(this,opt)





    pValue=[];

    adRG=rptgen.appdata_rg;
    opt.interpreter=rptgen.toString(opt.interpreter);
    switch lower(opt.interpreter)
    case 'tex'
        pValue=getTEXMarkup(opt,adRG.CurrentDocument);
    case 'rich'
        if opt.isDOM&&~(this.isParentParagraph)
            pValue=getHTMLMarkup(opt,adRG.CurrentDocument);
        end
    end
    if isempty(pValue)
        pValue=getParaMarkup(opt,adRG.CurrentDocument);
    end

end

function out=getTEXMarkup(opt,d)
    equationText=rptgen.toString(opt.dValue);
    fontSize=14;
    switch opt.format
    case{'dom-docx','dom-pdf','rtf97','doc-rtf'}
        if ispc
            ext='emf';
            format='-dmeta';
        else
            ext='png';
            format='-dpng';
            fontSize=8;
        end
    otherwise
        ext='svg';
        format='-dsvg';
    end
    adRG=rptgen.appdata_rg;
    img=adRG.getImgName(ext,'latex');
    texWarning=rptgen.createEquationImage(...
    img.fullname,equationText,format,fontSize);%#ok<NASGU>

    mediaobject=d.createElement('mediaobject');
    imageobject=d.createElement('imageobject');
    imagedata=d.createElement('imagedata');
    imagedata.setAttribute('fileref',img.relname);
    imagedata.setAttribute('scalefit','1');
    imageobject.appendChild(imagedata);
    mediaobject.appendChild(imageobject);

    out=mediaobject;
end

function out=getHTMLMarkup(opt,d)
    html=rptgen.toString(opt.dValue);
    out=d.createElement('markup');
    out.setAttribute('role','html2dom');

    html=mlreportgen.utils.tidy(html,...
    'ConfigFile',fullfile(toolboxdir("shared"),'mlreportgen','utils','resources','tidy-xhtml-no-wrap.cfg'));
    model=RptgenSL.getReportedModel();
    unpackedLocation=get_param(model,'UnpackedLocation');
    html=strrep(html,'[$unpackedFolder]',unpackedLocation);
    joTextValue=d.createTextNode(html);
    out.appendChild(joTextValue);
end

function out=getParaMarkup(opt,d)
    str=rptgen.toString(opt.dValue);

    if~isempty(regexp(str,'\s','once'))
        out=d.createElement('programlisting');
    else
        out=d.createElement('para');
    end

    phrase=d.createElement('phrase',str);
    appendChild(out,phrase);
end



