function tList=getTemplateList(this,format,listAction)
















    tList=cell(0,2);
    if isempty(this.TemplateLibrary)&&nargin>2&&strcmpi(listAction,'-asynchronous')
        getTemplateLibrary(this,listAction);
        return;
    end

    if strcmpi(format,'-all')
        tLib=getTemplateLibrary(this);
        libCat=find(tLib,...
        '-depth',1,...
        '-not','Tag','empty');%#ok<GTARG>

    else
        if strcmpi(format(1:3),'dom')
            fmt=upper(format(5:end));
        else
            fmt=upper(format);
        end
        if strcmpi(format,'dom-pdf')
            fmt='DOCX';
        end
        if strcmpi(format,'dom-pdf-direct')
            fmt='PDF';
        end
        if strcmpi(format,'dom-html-file')||strcmpi(format,'html-file')
            fmt='HTMLFile';
        end
        libCat=this.(['Category',fmt]);
    end

    libTemplates=find(libCat,...
    '-depth',1,...
    '-isa','RptgenML.DB2DOMTemplateEditor');%#ok<GTARG>

    if isempty(libTemplates)
        return;
    end

    allID=get(libTemplates,'ID');
    allName=get(libTemplates,'DisplayName');

    if length(libTemplates)==1
        tList={allID,allName};
    else
        tList=[allID,allName];
    end


