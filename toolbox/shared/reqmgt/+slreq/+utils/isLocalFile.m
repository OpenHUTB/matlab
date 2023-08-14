function tf=isLocalFile(destData,domain)







    persistent domainTypeMap
    if isempty(domainTypeMap)



        domainTypeMap=buildDomainTypeMap();
    end

    if nargin==2

        doc=destData;

    elseif isa(destData,'slreq.datamodel.Reference')
        doc=destData.artifactUri;
        domain=destData.domain;

    elseif isa(destData,'slreq.data.Requirement')
        if destData.external
            doc=destData.artifactUri;
            domain=destData.domain;
        else
            tf=true;
            return;
        end

    else

        if isfield(destData,'doc')
            doc=destData.doc;
            domain=destData.reqsys;
        else
            doc=destData.artifactUri;
            domain=destData.domain;
        end
    end





    if isempty(doc)

        tf=false;
        return;
    end

    protoPrefix=[strfind(doc,'http://'),strfind(doc,'https://')];

    if any(protoPrefix==1)

        tf=false;

    elseif rmisl.isSidString(doc)





        tf=false;

    elseif isKey(domainTypeMap,domain)
        tf=domainTypeMap(domain);

    else


        customTypeAPI=rmi.linktype_mgr('resolveByRegName',domain);
        if~isempty(customTypeAPI)
            tf=customTypeAPI.isFile;
            domainTypeMap(domain)=tf;
        else
            tf=false;
        end
    end
end

function typesMap=buildDomainTypeMap()
    typesMap=containers.Map('KeyType','char','ValueType','logical');

    typesMap('linktype_rmi_simulink')=true;
    typesMap('linktype_rmi_text')=true;
    typesMap('linktype_rmi_html')=true;
    typesMap('linktype_rmi_word')=true;
    typesMap('linktype_rmi_excel')=true;
    typesMap('linktype_rmi_data')=true;
    typesMap('linktype_rmi_testmgr')=true;
    typesMap('linktype_rmi_matlab')=true;
    typesMap('linktype_rmi_pdf')=true;
    typesMap('linktype_rmi_slreq')=true;
    typesMap('other')=true;

    typesMap('doors')=false;
    typesMap('linktype_rmi_doors')=false;
    typesMap('linktype_rmi_url')=false;
    typesMap('linktype_rmi_oslc')=false;
end





