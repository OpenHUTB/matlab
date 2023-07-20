function d=document(docIn)










    d=rpt_xml.document;

    if nargin<1
        docIn='sect1';
    end

    if ischar(docIn)
        if rptgen.use_java
            docIn=javaObject('com.mathworks.toolbox.rptgencore.docbook.DocbookDocument',docIn);
        else
            docIn=rptgen.internal.docbook.DocbookDocument(docIn);
        end
    end

    d.Document=docIn;

    d.AnchorTable=containers.Map;