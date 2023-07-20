classdef SourcePath<handle





















    properties(Constant)
        FILE_PREFIX=slreq.uri.ImageSourceConstants.FILE_PREFIX_FOR_SOURCE_IN_HTML;
        PACKAGE_HASHSET_PREFIX=slreq.uri.ImageSourceConstants.PACKAGE_REQSET_BASE_PATH;
        RESOURCE=slreq.uri.ImageSourceConstants.RESOURCE_MACRO_VAR;
        SETRESOURCE=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;
        CACHED_FOLDER_LIST=slreq.uri.ImageSourceConstants.CACHED_LABEL_LISTFOR_IMPORT;
        RMI_TEMP_DIR=slreq.opc.getUsrTempDir;
    end

    properties(Access=private)
        ReqSetName;
        RmiSetTempDir;
        PathString;



        PathType;

        FullPath;
        ResourcePath;
        ResourceMacro;
        PackagePath;


        Debug=false;

        NeedRefresh=false;
    end

    methods

        function this=SourcePath(pathString)


            pathString=strrep(pathString,this.FILE_PREFIX,'');
            this.PathString=pathString;
            this.refreshPathType();
        end


        function setReqSetName(this,reqSetName)
            this.ReqSetName=reqSetName;
            this.RmiSetTempDir=slreq.opc.getReqSetTempDir(reqSetName);
            this.NeedRefresh=true;
        end


        function out=getPathType(this)
            if isempty(this.PathType)||this.NeedRefresh
                this.refreshPathType();
                this.NeedRefresh=false;
            end
            out=this.PathType;
        end


        function setPathType(this,pathType)
            this.PathType=slreq.uri.SourcePathType.(pathType);
        end


        function out=getResourcePath(this)
            if isempty(this.ResourcePath)||this.NeedRefresh
                this.getResourcePath_();
                this.NeedRefresh=false;
            end
            out=this.ResourcePath;
        end


        function out=getPackagePath(this)
            if isempty(this.PackagePath)||this.NeedRefresh
                this.getPackagePath_();
                this.NeedRefresh=false;
            end
            out=this.PackagePath;
        end


        function out=getFullPath(this)
            if isempty(this.FullPath)||this.NeedRefresh
                this.getFullPath_();
                this.NeedRefresh=false;
            end
            out=this.FullPath;

        end


        function out=getResourceMacro(this)
            out=this.ResourceMacro;
        end


        function setResourceMacro(this,macroName)
            this.ResourceMacro=macroName;
        end


        function out=isInternalMacro(this)
            out=strcmp(this.ResourceMacro,this.RESOURCE);
        end


        function out=isExternalMacro(this)
            out=strcmp(this.ResourceMacro,this.SETRESOURCE);
        end
    end


    methods(Access=private)

        function refreshPathType(this)
            pathString=this.PathString;
            if startsWith(pathString,this.RESOURCE)
                this.PathType=slreq.uri.SourcePathType.ResourcePath;
                this.ResourceMacro=this.RESOURCE;
            elseif startsWith(pathString,this.SETRESOURCE)
                this.PathType=slreq.uri.SourcePathType.ResourcePath;
                this.ResourceMacro=this.SETRESOURCE;
            elseif startsWith(pathString,this.PACKAGE_HASHSET_PREFIX)
                this.PathType=slreq.uri.SourcePathType.PackagePath;
                this.ResourceMacro=this.SETRESOURCE;
            elseif startsWith(pathString,this.CACHED_FOLDER_LIST)



                this.PathType=slreq.uri.SourcePathType.PackagePath;
                this.ResourceMacro=this.RESOURCE;
            elseif rmiut.isCompletePath(pathString)
                this.PathType=slreq.uri.SourcePathType.FullPath;
            else
                error('unexpected path type');
            end
        end




        function getFullPath_(this)
            pathString=this.PathString;

            if this.PathType.isFullPath()
                this.FullPath=pathString;
                return;
            end

            if this.PathType.isResourcePath()
                this.FullPath=this.convertResourcePathToFullPath();
                return;
            end

            if this.PathType.isPackagePath()
                this.FullPath=this.convertPackagePathToFullPath();
                return;
            end
        end


        function getResourcePath_(this)
            pathString=this.PathString;

            if this.PathType.isResourcePath()
                this.ResourcePath=pathString;
                return;
            end

            if this.PathType.isFullPath()
                this.ResourcePath=this.convertFullPathToResourcePath();
                return;
            end

            if this.PathType.isPackagePath()
                this.ResourcePath=this.convertPackagePathToResourcePath();
                return;
            end
        end


        function getPackagePath_(this)
            pathString=this.PathString;

            if this.PathType.isPackagePath()
                this.PackagePath=pathString;
                return;
            end

            if this.PathType.isFullPath()

                this.PackagePath=this.convertFullPathToPackagePath();
                return;
            end

            if this.PathType.isResourcePath()
                this.PackagePath=this.convertResourcePathToPackagePath();
                return;
            end
        end


        function out=convertFullPathToPackagePath(this)
            if this.Debug
                fprintf(2,'Do not use this unless you really want to convert full path to package.  normally, we should convert resource path to package path.\n');
            end

            fullpathStr=unixStr(this.PathString);

            if this.isInternalMacro()
                usrTemp=this.RMI_TEMP_DIR;
                out=strrep(fullpathStr,usrTemp,'');
            elseif this.isExternalMacro()
                assert(~isempty(this.ReqSetName),'ReqSetName is not set in SourcePath');
                usrTemp=this.RmiSetTempDir;
                if contains(fullpathStr,usrTemp)
                    out=strrep(fullpathStr,[usrTemp,'/'],this.PACKAGE_HASHSET_PREFIX);
                else

                    usrTemp=this.RMI_TEMP_DIR;
                    out=strrep(fullpathStr,usrTemp,'');
                end
            else


                usrTemp=this.RMI_TEMP_DIR;
                out=strrep(fullpathStr,usrTemp,'');
            end
        end


        function out=convertFullPathToResourcePath(this)







            fullpathStr=unixStr(this.PathString);
            if this.isInternalMacro()
                usrTemp=this.RMI_TEMP_DIR;
            elseif this.isExternalMacro()
                assert(~isempty(this.ReqSetName),'ReqSetName is not set in SourcePath');
                usrTemp=this.RmiSetTempDir;
                if~contains(fullpathStr,usrTemp)

                    usrTemp=this.RMI_TEMP_DIR;
                end
            else
                error('Invalid Resource Macro Given')
            end
            out=strrep(fullpathStr,usrTemp,this.ResourceMacro);
        end


        function out=convertResourcePathToPackagePath(this)





            if this.isInternalMacro()
                out=strrep(this.PathString,this.RESOURCE,'');
            elseif this.isExternalMacro()
                out=strrep(this.PathString,[this.SETRESOURCE,'/'],this.PACKAGE_HASHSET_PREFIX);
            end
        end


        function out=convertResourcePathToFullPath(this)






            if this.isInternalMacro()
                out=strrep(this.PathString,this.RESOURCE,this.RMI_TEMP_DIR);
            elseif this.isExternalMacro()
                out=strrep(this.PathString,this.SETRESOURCE,this.RmiSetTempDir);
            end
        end


        function out=convertPackagePathToFullPath(this)







            if this.isInternalMacro()
                out=[this.RMI_TEMP_DIR,this.PathString];
            elseif this.isExternalMacro()
                out=strrep(this.PathString,this.PACKAGE_HASHSET_PREFIX,[this.RmiSetTempDir,'/']);
            end
        end


        function out=convertPackagePathToResourcePath(this)







            if this.isInternalMacro()
                out=[this.RESOURCE,this.PathString];
            elseif this.isExternalMacro()
                out=strrep(this.PathString,this.PACKAGE_HASHSET_PREFIX,[this.SETRESOURCE,'/']);
            end
        end
    end

    methods(Static)


        function updateMacroForDescriptionAndRationale(mfReqSet,reqSetName)








            dstBaseName=slreq.opc.getReqSetDirBaseName(reqSetName);
            macroForOldRelease=slreq.uri.ImageSourceConstants.RESOURCE_MACRO_VAR;
            macroForCurrentRelease=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;
            newFolder=[macroForOldRelease,'/',dstBaseName,'/'];
            oldFolder=[macroForCurrentRelease,'/'];
            dataReqList=mfReqSet.items.toArray;
            for index=1:length(dataReqList)
                cReqItem=dataReqList(index);


                cReqItem.description=strrep(cReqItem.description,oldFolder,newFolder);
                cReqItem.rationale=strrep(cReqItem.rationale,oldFolder,newFolder);
            end
        end
    end

end

function outStr=unixStr(inStr)
    if ispc
        outStr=strrep(inStr,'\','/');
    else
        outStr=inStr;
    end

end
