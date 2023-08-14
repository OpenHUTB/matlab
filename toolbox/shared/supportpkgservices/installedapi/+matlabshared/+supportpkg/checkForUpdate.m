function info=checkForUpdate(varargin)



















    p=inputParser;
    p.CaseSensitive=false;
    p.addParameter('BaseProduct',[],@locValidateBaseProduct);
    p.addParameter('ReturnBaseCodes',false,@islogical)
    p.parse(varargin{:});

    baseProductList=p.Results.BaseProduct;


    hasInternetAccess=locHasInternetAccess;
    if~hasInternetAccess
        error(message('supportpkgservices:matlabshared:NoInternetAccess'));
    end


    [pkgInfo,status]=locGetPkgInfo(baseProductList,p.Results.ReturnBaseCodes);


    if nargout==0
        if~isempty(pkgInfo)
            locPrintInfo(pkgInfo);
        else
            if status==1
                disp(message('supportpkgservices:matlabshared:NoInstalled').getString);
            else
                disp(message('supportpkgservices:matlabshared:NoUpdate').getString);
            end
        end
    else
        info=pkgInfo;
    end

end


function hasInternetAccess=locHasInternetAccess
    hasInternetAccess=canAccessSupportFiles();

end

function testUrl=getInternetAccessTestUrl()
    urlMgr=matlab.internal.UrlManager;
    testUrl=[char(urlMgr.MATHWORKS_DOT_COM),'/supportfiles/supportpackages/resources/access_check.txt'];
end

function out=webAccessCheck





    out=getenv('SUPPORTPACKAGE_INSTALLER_WEBACCESSCHECK');
    if~any(strcmpi(out,{'','assume_access','assume_no_access'}))
        out='';
    end
end

function retval=canAccessSupportFiles()
    accessCheck=webAccessCheck();
    if strcmpi(accessCheck,'assume_access')
        retval=true;
        return;
    elseif strcmpi(accessCheck,'assume_no_access')
        retval=false;
        return;
    end

    try
        testUrl=getInternetAccessTestUrl();
        webread(testUrl);
        retval=true;
    catch %#ok<CTCH>

        retval=false;
    end
end




function[spList,status]=locGetPkgInfo(baseProductList,returnBaseCodes)

    installedPkgList=matlabshared.supportpkg.internal.getInstalledImpl();

    spList=[];
    status=0;

    if isempty(installedPkgList)
        status=1;
        return;
    end

    webPkgList=localGetPackageListFromWeb();
    packageInfo=matlabshared.supportpkg.internal.util.getUpdatablePackages(installedPkgList,webPkgList);
    if~isempty(baseProductList)
        prodList=cellstr(baseProductList);
    end

    for i=1:numel(packageInfo)
        if(localCompareVersion(packageInfo(i).LatestVersion,packageInfo(i).InstalledVersion)>0)...
            &&(isempty(baseProductList)||ismember(packageInfo(i).BaseProduct,prodList))

            info=struct('Name',packageInfo(i).DisplayName,...
            'LatestVersion',packageInfo(i).LatestVersion,...
            'InstalledVersion',packageInfo(i).InstalledVersion,...
            'BaseProduct',packageInfo(i).BaseProduct);


            if returnBaseCodes
                info.BaseCode=packageInfo(i).BaseCode;
            end
            spList=[spList,info];%#ok<AGROW>
        end
    end

end


function ret=localCompareVersion(v1,v2)
    va=str2double(strsplit(v1,'.'));
    vb=str2double(strsplit(v2,'.'));
    maxlen=max(length(va),length(vb));
    va(end+1:maxlen)=0;
    vb(end+1:maxlen)=0;
    index=find(va~=vb,1,'first');
    if isempty(index)
        ret=0;
    elseif va(index)>vb(index)
        ret=+1;
    else
        ret=-1;
    end
end

function pkgList=localGetPackageListFromWeb()




    MANIFEST_FILENAME='package_registry.xml';
    [xmlHttp,isLocalCopyFile]=getManifestLocation();

    try
        localXmlFile=[tempname,'.xml'];
        if isLocalCopyFile
            status=copyfile(localConvertToLinuxPath(xmlHttp,MANIFEST_FILENAME),localXmlFile);
            assert(status==1);
        else
            websave(localXmlFile,...
            localConvertToLinuxPath(xmlHttp,MANIFEST_FILENAME),...
            weboptions('Timeout',10));
        end

    catch ex
        newEx=MException('supportpkgservices:matlabshared:ManifestDownload',message('supportpkgservices:matlabshared:ManifestDownload').getString);
        newEx.addCause(ex);
        throw(newEx);
    end

    pkgList=localLoadPkgInfo(localXmlFile,matlabshared.supportpkg.internal.getCurrentRelease());
end

function[urlLoc,isLocalFileCopy]=getManifestLocation()
    manifestLoc=overrideManifestLocation();
    if~isempty(manifestLoc)
        if strncmpi(manifestLoc,'http',4)
            isLocalFileCopy=false;
            urlLoc=manifestLoc;
        else
            isLocalFileCopy=true;
            urlLoc=getPlatformUrlLoc();
        end
    else
        urlMgr=matlab.internal.UrlManager;
        mwBaseUrl=char(urlMgr.MATHWORKS_DOT_COM);
        releaseTag=localGetReleaseTag(matlabshared.supportpkg.internal.getCurrentRelease(),'matchcase');



        urlLoc=[mwBaseUrl,'/supportfiles/supportpackages/',releaseTag];
        isLocalFileCopy=false;
    end
    function out=getPlatformUrlLoc()
        manifestLocFS=strrep(manifestLoc,'\','/');
        if ispc
            out=['file:/',manifestLocFS,'/'];
        else
            out=['file:',manifestLocFS,'/'];
        end
    end
end

function spPkg=localLoadPkgInfo(localXmlFile,mlrelease)
    import matlab.io.xml.dom.*
    spPkg=struct(...
    'BaseCode','',...
    'Version','');

    if~(exist(localXmlFile,'file')==2)
        error(message('supportpkgservices:matlabshared:ManifestDoesNotExist',localXmlFile));
    end


    xmlParseError=false;
    try
        domNode=parseFile(Parser,localXmlFile);
    catch
        xmlParseError=true;
    end

    if xmlParseError
        error(message('supportpkgservices:matlabshared:CorruptedManifest'));
    end

    pkgrepository=domNode.getDocumentElement();
    matlabreleases=pkgrepository.getElementsByTagName('MatlabRelease');
    currrelease=localGetElement(matlabreleases,mlrelease,'name');
    if isempty(currrelease)
        error(message('supportpkgservices:matlabshared:UnsupportedRelease',mlrelease));
    end
    packages=currrelease.getElementsByTagName('SupportPackage');
    for i=0:packages.getLength-1
        currpkg=packages.item(i);
        spPkg(i+1).Version=char(currpkg.getAttribute('version'));
        spPkg(i+1).BaseCode=char(currpkg.getAttribute('basecode'));
    end
end

function domelement=localGetElement(domobj,attribute,attributename)
    domelement=[];
    for i=0:domobj.getLength-1
        currdomobj=domobj.item(i);
        if strcmp(char(attribute),...
            char(currdomobj.getAttribute(attributename)))
            domelement=currdomobj;
            break;
        end
    end
end

function relTag=localGetReleaseTag(release,opts)



    relTag=regexprep(release,'[\s|(|)]','');
    if~exist('opts','var')||~strcmpi(opts,'matchcase')
        relTag=lower(relTag);
    end
end

function out=overrideManifestLocation
    out=getenv('SUPPORTPACKAGE_INSTALLER_MANIFEST_LOCATION');
end

function file=localConvertToLinuxPath(varargin)
    file=strrep(varargin{1},'\','/');
    for i=2:nargin
        file=[file,'/',varargin{i}];%#ok<AGROW>
    end
    file=regexprep(file,'/$','');
end





function locPrintInfo(spInfo)
    infoTable=internal.DispTable();
    infoTable.addColumn(message('supportpkgservices:matlabshared:Name').getString);
    infoTable.addColumn(message('supportpkgservices:matlabshared:Installed').getString);
    infoTable.addColumn(message('supportpkgservices:matlabshared:Latest').getString);
    infoTable.addColumn(message('supportpkgservices:matlabshared:BaseProduct').getString);
    for i=1:numel(spInfo)
        infoTable.addRow(spInfo(i).Name,spInfo(i).InstalledVersion,spInfo(i).LatestVersion,spInfo(i).BaseProduct);
    end
    infoTable.disp
end


function locValidateBaseProduct(product)
    if iscell(product)
        for i=1:length(product)
            if isempty(product{i})||(~ischar(product{i})&&(~isstring(product{i})&&isscalar(product{i})))
                error(message('supportpkgservices:matlabshared:WrongBaseProductValue'));
            end
        end
    else
        if isempty(product)||(~ischar(product)&&(~isstring(product)&&isscalar(product)))
            error(message('supportpkgservices:matlabshared:WrongBaseProductValue'));
        end
    end
end
