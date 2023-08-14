classdef(Sealed)SignpostReader<hwconnectinstaller.Signpost



















    methods
        function obj=SignpostReader(xmlFileName)
            [info,signature]=parseSignpostXml(xmlFileName);
            obj=obj@hwconnectinstaller.Signpost(info);

            if~verifySignature(obj,signature)
                error(message('hwconnectinstaller:setup:Signpost_Tampered',xmlFileName));
            end

        end
    end


end


function[info,signatureStr]=parseSignpostXml(xmlFileName)

    if~exist(xmlFileName,'file')
        error(message('hwconnectinstaller:setup:Signpost_NonExistentFile',xmlFileName));
    end



    try
        domNode=readstruct(xmlFileName,'FileType',"xml");
    catch %#ok<CTCH>
        error(message('hwconnectinstaller:setup:Signpost_Unreadable',xmlFileName));
    end


    expectedVersion='1.0';
    try
        pkginfoItems=domNode.PackageInfo;
        numItems=size(pkginfoItems,2);
    catch %#ok<CTCH>
        error(message('hwconnectinstaller:setup:Signpost_MissingXMLElement',xmlFileName));
    end

    found=false;
    for i=1:numItems
        pkginfo=pkginfoItems(i);
        version=sprintf('%.1f',pkginfo.versionAttribute);
        if strcmp(version,expectedVersion)
            found=true;
            break;
        end
    end

    if~found
        error(message('hwconnectinstaller:setup:Signpost_VersionNotFound',xmlFileName,expectedVersion));
    end

    try
        spdata=pkginfo.SignpostData;
        signatureStr=char(pkginfo.Signature);

        info.SignpostVersion=version;
        info.Repository=char(spdata.Repository);
        info.PackageName=char(spdata.Name);
        info.BaseProduct=char(spdata.BaseProduct);
        info.FullName=char(spdata.FullName);
    catch %#ok<CTCH>
        error(message('hwconnectinstaller:setup:Signpost_MissingXMLElement',xmlFileName));
    end





    info.BaseCode='%%LEGACYSIGNPOST%%';
    try
        if strlength(spdata.BaseCode)~=0
            info.BaseCode=char(spdata.BaseCode);
        end
    catch ex

        hwconnectinstaller.internal.inform(sprintf('No basecode found in signpost file: %s\nException: %s',xmlFileName,ex.message));
    end

end
