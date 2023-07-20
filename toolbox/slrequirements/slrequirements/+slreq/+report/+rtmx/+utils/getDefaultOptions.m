function options=getDefaultOptions(type)

    if nargin==0
        type='struct';
    end

    options.leftArtifacts={};
    options.topArtifacts={};

    if strcmpi(type,'struct')
        options.openArtifactSelector=false;
        options.configuration.top=getDefaultProp;
        options.configuration.left=getDefaultProp;
        options.configuration.cell=getDefaultProp;
        options.configuration.highlight=getDefaultProp;
        options.configuration.matrix=getDefaultProp;

    else


    end



















































































































































end

function out=getDefaultProp()
    out=struct('Domain',{},'Name',{},'Prop',{},'QueryName',{});
end

function out=getDefaultConfiguration()
    out.highlight.missingLinks=false;
    out.highlight.withChangeIssues=false;
    out.filter=getDefaultFilters();

end

function out=getDefaultFilters()
    out.matrix.withChangeIssues=true;
    out.cell.types={};
    out.cell.withChangeIssues=false;
    out.top=getDefaultArtifactFilters();
    out.left=getDefaultArtifactFilters();
end

function out=getDefaultArtifactFilters()
    out.domainList={};
    out.scope={};
    out.missingLinks=false;
    out.slrqx=getDefaultConfigForDomain('slreqx');
    out.slx=getDefaultConfigForDomain('slx');
    out.m=getDefaultConfigForDomain('m');
    out.sldd=getDefaultConfigForDomain('sldd');
    out.mldatx=getDefaultConfigForDomain('mldatx');
end

function out=getDefaultConfigForDomain(domainName)
    out.type={};
    switch domainName
    case 'slreqx'
        out.hasChangeIssuesOnly=false;
        out.customerAttributes=struct;
        out.keywords={};
    case 'slx'
        out.missingExpectedLinksOnly=false;
    case 'm'
    case 'mldatx'
        out.tags={};
    case 'sldd'
    end
end

function out=createConfigInfo(propList)
    out=containers.Map('keytype','char','valuetype','any');
    for index=1:length(propList)
        cProp=propList{index};
        out(cProp.name)=cProp;
    end
end

function out=createPropStruct(name,domain,value)
    out.name=name;
    out.domain=domainList;
    out.value=value;
end