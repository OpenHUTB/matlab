function[url,errMsg]=getMwItemUrl(mwItem)







    errMsg='';

    if isstruct(mwItem)&&~isfield(mwItem,'artifactUri')

        mwItem.artifactUri=mwItem.artifact;
    end

    mwNavigationUrlBase='https://127.0.0.1:31515/matlab/oslc/navigate';
    artifact=slreq.uri.getShortNameExt(mwItem.artifactUri);
    mwNavigationUrlParams=sprintf('domain=%s&artifact=%s&id=%s',mwItem.domain,artifact,mwItem.id);

    url=[mwNavigationUrlBase,'?',mwNavigationUrlParams];


    if connector.securePort~=31515
        errMsg=getString(message('Slvnv:rmiut:matlabConnectorOn:matlabConnectorWrongPortLine1',num2str(connector.securePort)));
    end
end
