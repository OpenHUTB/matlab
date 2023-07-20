function out=execute(this,d,varargin)




    blkList=findContextBlocks(rptgen_sl.appdata_sl,'MaskType','\<DocBlock\>');

    out=d.createDocumentFragment;

    if this.LinkingAnchor
        ps=rptgen_sl.propsrc_sl_blk;
    else
        ps=[];
    end

    for i=1:length(blkList)

        if~isempty(ps)
            out.appendChild(ps.makeLinkScalar(blkList{i},'blk','anchor',d,''));
        end

        try
            docType=lower(get_param(blkList{i},'DocumentType'));
        catch ME
            this.status(getString(message('RptgenSL:rsl_csl_blk_doc:couldNotFindTypeLabel')),4);
            this.status(ME.message,5);
            docType='txt';
        end

        switch docType
        case{'rtf','doc','html','htm'}
            adRG=rptgen.appdata_rg;






            dbFile=adRG.getImgName(docType,'DocBlock');



            adRG.PostConvertImport=true;

            docblock('blk2file',blkList{i},dbFile.fullname);

            if(docType=="html")



                mlreportgen.utils.html2dom.prepHTMLFile(dbFile.fullname,dbFile.fullname,"Tidy",false)
            end


            dispName=blkList{i};
            if length(dispName)>32
                dispName=[dispName(1:15),'...',dispName(end-15:end)];
            end

            try
                if rptgen.use_java
                    iNode=com.mathworks.toolbox.rptgencore.docbook.FileImporter.importExternalFile(...
                    dbFile.relname,...
                    java(d),...
                    dispName);
                else
                    iNode=rptgen.internal.docbook.FileImporter.importExternalFile(...
                    dbFile.relname,...
                    d.Document,...
                    dispName);
                end

                iNode.setAttribute("convertHTML",string(this.ConvertHTML));
                iNode.setAttribute("embedFile",string(this.EmbedFile));

            catch ME
                iNode=[];
                status(this,sprintf(getString(message('RptgenSL:rsl_csl_blk_doc:couldNotImportLabel')),blkList{i}),1);
                status(this,ME.message,5,0);
            end

        otherwise



            fName=[tempname,'.txt'];

            docblock('blk2file',blkList{i},fName);

            try
                if rptgen.use_java
                    iNode=com.mathworks.toolbox.rptgencore.docbook.FileImporter.importFile(...
                    this.ImportType,...
                    fName,...
                    'utf-8',...
                    java(d));
                else
                    iNode=rptgen.internal.docbook.FileImporter.importFile(...
                    this.ImportType,...
                    fName,...
                    'utf-8',...
                    d.Document);
                end
            catch ME
                iNode=[];
                status(this,sprintf(getString(message('RptgenSL:rsl_csl_blk_doc:couldNotImportLabel')),blkList{i}),2);
                status(this,ME.message,5,0);
            end

            delete(fName);

        end

        if~isempty(iNode)
            out.appendChild(iNode);
        end


    end

