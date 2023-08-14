function linkType=linktype_rmi_sequenceDiagramQuasiAnnotation















    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;


    linkType.Label='SequenceDiagram';


    thisFunction=mfilename('fullpath');
    qaFolder=fileparts(fileparts(thisFunction));
    imagesFolder=fullfile(qaFolder,'images');
    iconPath=fullfile(imagesFolder,'sequence_diagram_16.png');
    linkType.Icon=iconPath;


    linkType.IsFile=0;
    linkType.Extensions={'.mat'};


    linkType.LocDelimiters='@';
    linkType.Version='';

    linkType.NavigateFcn=@NavigateFcn;
    linkType.IsValidIdFcn=@IsValidIdFcn;

end

function NavigateFcn(qaMatFile,uuid)
    sequencediagram.quasiannotation.Requirement.navigateToRequirement(qaMatFile,uuid)
end

function tf=IsValidIdFcn(qaMatFile,uuid)
    tf=sequencediagram.quasiannotation.Requirement.isValidId(qaMatFile,uuid);
end


