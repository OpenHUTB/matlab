function[hdlblkinfo,deprInfo,hdlblkInfoHide,helpInfo]=getImplementationInfoForBlock(this,blkTag,filterHidden,curArch,blockHandle)




    if nargin<5
        blockHandle=-1;
    end

    helpInfo=[];

    if nargin<4||isempty(curArch)
        curArch='';
        if blockHandle~=-1
            hd=get_param(blockHandle,'HDLData');

            if~isempty(hd)
                curArch=hd.getCurrentArch;
            end
        end
    end

    if nargin<3
        filterHidden=false;
    end


    hdlblkinfo=containers.Map;
    deprInfo=[];
    hdlblkInfoHide=containers.Map;

    if~isempty(blkTag)

        implList=this.getImplementationsFromBlock(blkTag);
        for ii=1:length(implList)
            impl=implList{ii};

            implObj=eval(impl);
            if implObj.Hidden
                if filterHidden

                    continue;
                end
            end
            if~implObj.validBlockMask(blockHandle)
                continue;
            end
            implInfo=implObj.getImplParamInfo;

            if~isempty(implInfo)
                implInfo=implObj.truncateImplParams(blockHandle,implInfo);
            end

            implName=implObj.getArchitectureName;
            hdlblkinfo(implName)=implInfo;
            helpInfo=implObj.getHelpInfo(blkTag);

            if~isempty(implObj.DeprecatedArchName)
                diName=implObj.DeprecatedArchName;
                if~isempty(curArch)
                    if(strcmpi(curArch,diName{1}))
                        deprInfo.oldName=diName{1};
                        deprInfo.newName=implName;
                    end
                else

                    if isempty(deprInfo)
                        deprInfo.oldName=diName{1};
                        deprInfo.newName=implName;
                    end
                end
            end

            hiddenParams={};



            if any(strcmp(methods(implObj),'hideImplParams'))
                hiddenParams=implObj.hideImplParams(blockHandle,implInfo);
            end
            hdlblkInfoHide(implName)=hiddenParams;
        end
    end
