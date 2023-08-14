function outputTemplateFile=exportModelToTemplate(modelName,destinationTemplate,varargin)





    modelName=get_param(modelName,'Name');
    bdtype=get_param(modelName,'BlockDiagramType');
    bdtype(1)=upper(bdtype(1));

    [~,fileName,givenExt]=fileparts(destinationTemplate);

    if~isvarname(fileName)
        DAStudio.error('sltemplate:Package:InvalidFileName',fileName);
    end

    if isempty(givenExt)
        destinationTemplate=[destinationTemplate,sltemplate.internal.Constants.getTemplateFileExtension];
    end

    sltemplate.internal.utils.throwIfInvalidFileExtension(destinationTemplate);

    p=inputParser;
    p.addParameter('Title',modelName,@isscalarstring);
    p.addParameter('Author',get_param(modelName,'Creator'),@isscalarstring);
    p.addParameter('Description',get_param(modelName,'Description'),@isscalarstring);
    p.addParameter('Group',sltemplate.internal.Constants.getDefaultTemplateGroup(),@isscalarstring);
    p.addParameter('ThumbnailFile','',@isscalarstring);
    p.addParameter('WarningHandler',@warning,@(x)isa(x,'function_handle'));
    p.addParameter('ProductDependencies',{},@iscellstr);
    p.parse(varargin{:});

    function isscalarstring(v)
        validateattributes(v,{'char','string'},{'scalartext'});
    end

    if sltemplate.internal.utils.isInBuiltinGroup(p.Results.Group)
        DAStudio.error('sltemplate:Package:CannotAddToBuiltinGroup',p.Results.Group);
    end

    unpackedLocation=tempname;

    if(~mkdir(unpackedLocation))
        DAStudio.error('sltemplate:Package:WriteTempError',destinationTemplate,unpackedLocation);
    end

    c=onCleanup(@()rmdir(unpackedLocation,'s'));
    snapshotFileName=[modelName,'.slx'];
    snapshotFullFilePath=fullfile(unpackedLocation,snapshotFileName);
    slInternal('snapshot_slx',modelName,snapshotFullFilePath);

    thumbnailFile=char(p.Results.ThumbnailFile);

    if isempty(thumbnailFile)

        thumbnailFile=fullfile(unpackedLocation,'thumbnail.png');
        sltemplate.internal.utils.createThumbnailFromModel(thumbnailFile,modelName);
    end

    if ismember('ProductDependencies',p.UsingDefaults)
        productDependencies=sltemplate.internal.findProductDependenciesForModel(snapshotFullFilePath);
    else
        productDependencies=p.Results.ProductDependencies;
    end


    writer=matlab.internal.project.packaging.PackageWriter;
    writer.Title=char(p.Results.Title);
    writer.Type=bdtype;
    writer.Author=char(p.Results.Author);
    writer.Description=char(p.Results.Description);
    writer.Group=char(p.Results.Group);
    writer.ThumbnailFile=thumbnailFile;
    writer.addFileToPackage(snapshotFullFilePath,snapshotFileName);
    cellfun(@(x)writer.addRequiredProduct(x),productDependencies,'UniformOutput',false);
    if Simulink.internal.isArchitectureModel(modelName)


        writer.addKeyword("Architecture");
    end
    writer.writePackage(destinationTemplate);

    outputTemplateFile=destinationTemplate;


    onPath=sltemplate.internal.Registrar.addTemplate(outputTemplateFile);


    set_param(modelName,"TemplateFilePath",outputTemplateFile);

    if~onPath
        p.Results.WarningHandler(...
        message('sltemplate:Registry:TemplateNotOnPath',outputTemplateFile));
    end

end


