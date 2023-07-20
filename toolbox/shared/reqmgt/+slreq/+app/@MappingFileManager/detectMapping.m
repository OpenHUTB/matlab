










function[mappingInfo,errorDetails]=detectMapping(this,srcDoc)

    mappingInfo='';
    errorDetails='';

    if isempty(srcDoc)
        return;
    end


    if this.parsedDocs.isKey(srcDoc)
        docInfo=this.parsedDocs(srcDoc);
    else
        [docInfo,~,errorDetails]=this.getSourceTool(srcDoc);

        if~isempty(docInfo)
            this.parsedDocs(srcDoc)=docInfo;
        end
    end


    if~isempty(docInfo)
        sourceToolId=docInfo.sourceToolId;

        mappingInfo=this.findMapping(sourceToolId);
    end

    if~isempty(mappingInfo)

        mappingInfo.specNames=docInfo.specNames;
        mappingInfo.hasLinks=docInfo.hasLinks;
    else

        mappingInfo=this.getGenericMapping();
        if~isempty(docInfo)

            mappingInfo.specNames=docInfo.specNames;
            mappingInfo.hasLinks=docInfo.hasLinks;
        else
            mappingInfo.specNames={};

            mappingInfo.hasLinks=false;
        end
    end
end
