function[destInfo,mpCount]=migrateMupadDestination(destInfo)





    mpCount=0;
    for i=1:length(destInfo)
        [fDir,fName,fExt]=fileparts(destInfo(i).doc);
        if~isMuPAD(destInfo(i).reqsys,fExt)
            continue;
        end

        destInfo(i).reqsys='linktype_rmi_matlab';
        destInfo(i).doc=fullfile(fDir,[fName,'.mlx']);
        destInfo(i).description=sprintf('%s (%s)',...
        destInfo(i).description,...
        getString(message('Slvnv:reqmgt:linktype_rmi_mupad:MuPADLinkConverted','MuPAD')));
        mpCount=mpCount+1;
    end

end

function tf=isMuPAD(domain,fext)
    switch domain
    case 'linktype_rmi_mupad'
        tf=true;
    case 'other'
        tf=strcmp(fext,'.mn');
    otherwise
        tf=false;
    end
end

