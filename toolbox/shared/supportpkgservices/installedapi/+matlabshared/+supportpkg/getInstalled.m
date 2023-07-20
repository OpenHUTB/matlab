function info=getInstalled(varargin)















    p=inputParser;
    p.CaseSensitive=false;
    p.addParamValue('BaseProduct',[],@locValidateBaseProduct);
    p.parse(varargin{:});

    baseProductList=p.Results.BaseProduct;


    pkgInfo=locGetPkgInfo(baseProductList);


    if nargout==0
        if~isempty(pkgInfo)
            locPrintInfo(pkgInfo);
        else
            disp(message('supportpkgservices:matlabshared:NoInstalled').getString);
        end
    else
        info=pkgInfo;
    end

end



function spList=locGetPkgInfo(baseProductList)

    installedPkgList=matlabshared.supportpkg.internal.getInstalledImpl();

    if~isempty(baseProductList)
        prodList=cellstr(baseProductList);
    end

    spList=[];
    for i=1:numel(installedPkgList)
        if installedPkgList(i).Visible...
            &&(isempty(baseProductList)...
            ||ismember(installedPkgList(i).BaseProduct,prodList))
            info=struct('Name',installedPkgList(i).DisplayName,...
            'InstalledVersion',installedPkgList(i).Version,...
            'BaseProduct',installedPkgList(i).BaseProduct);
            spList=[spList,info];
        end
    end

end



function locPrintInfo(spInfo)
    infoTable=internal.DispTable();
    infoTable.addColumn(message('supportpkgservices:matlabshared:Name').getString);
    infoTable.addColumn(message('supportpkgservices:matlabshared:Version').getString);
    infoTable.addColumn(message('supportpkgservices:matlabshared:BaseProduct').getString);
    for i=1:numel(spInfo)
        infoTable.addRow(spInfo(i).Name,spInfo(i).InstalledVersion,spInfo(i).BaseProduct);
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