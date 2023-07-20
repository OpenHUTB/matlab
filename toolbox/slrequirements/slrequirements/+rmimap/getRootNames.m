function rootData=getRootNames(type)

    if nargin<1
        type='';
    end






    [sourceData,destData]=slreq.data.ReqData.getInstance.allRootItemsInfo();
    rootData=[sourceData;destData];
    if nargin>0

        for i=size(rootData,1):-1:1
            srcType=resolveSrcType(rootData{i,2},rootData{i,1});
            if~strcmp(srcType,type)
                rootData(i,:)=[];
            end
        end
    end






    rootData=slreq.utils.reconsileArtifactNames(rootData);

    if nargin>0
        rootData(:,2)=[];
    end

end

function srcType=resolveSrcType(storedType,artifact)
    srcType=storedType;
    if strcmp(srcType,'other')
        resolvedLinkType=rmi.linktype_mgr('resolveByFileExt',artifact);
        if~isempty(resolvedLinkType)
            srcType=resolvedLinkType.Registration;
        end
    end
end

