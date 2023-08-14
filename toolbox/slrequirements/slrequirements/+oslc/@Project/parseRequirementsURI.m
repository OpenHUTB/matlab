function reqInfo=parseRequirementsURI(rdf,isUI)
    if isUI
        rmiut.progressBarFcn('set',0.3,getString(message('Slvnv:oslc:GettingURIs')));
    end
    members=oslc.Project.getMembers(rdf);
    reqInfo=cell(size(members));
    if isUI
        rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:oslc:GettingURIs')));
    end
    for i=1:length(members)
        reqInfo{i}=oslc.parseValue(members{i},'oslc_rm:Requirement rdf:about=');
    end
end

