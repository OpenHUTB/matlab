



function out=parseMappingInfo(this,xmlFile)

    out=struct('name','','desc','','type','','fullpath','','template','');

    if isempty(xmlFile)
        return;
    end


    mfModel=mf.zero.Model();


    content=slreq.utils.readFromXML(xmlFile);
    if isempty(content)
        return;
    end




    slreq.datamodel.RequirementData.StaticMetaClass;

    try
        parser=mf.zero.io.XmlParser;
        parser.Model=mfModel;
        parser.RemapUuids=true;
        mfMapping=parser.parseString(content);
    catch ex
        mfMapping=[];
    end

    if isempty(mfMapping)
        return;
    end


    [fPath,~,~]=fileparts(xmlFile);

    resolvedTemplateFile='';
    templateFile=mfMapping.templateFile;
    if~isempty(templateFile)
        resolvedTemplateFile=fullfile(fPath,templateFile);


        if exist(resolvedTemplateFile,'file')~=2
            resolvedTemplateFile='';
        end
    end


    out=struct('name',mfMapping.name,...
    'desc',mfMapping.description,...
    'type',char(mfMapping.getDirection()),...
    'fullpath',xmlFile,...
    'template',resolvedTemplateFile);



    mfModel.destroy();
end