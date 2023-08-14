


classdef DependencyContainer<handle
    properties(Access=public)
        fName;
fNameWithPath
depFunPaths
depFuncNames

depStruct

resourceFcnList
resourceList
resExtMap

foundCallToDesign


checkFunctionCallFor


designCallerFileName
designCallerFilePath
doubleToSingle
    end
    properties(Access=private)
problemMap
    end

    methods(Access=private)
        function initMembers(this,whiteListPath,blackListPath,checkFileNameMismatch,checkFncHandles)
            this.depStruct=struct;
            this.depFuncNames=cell(0,0);
            this.depFunPaths=cell(0,0);
            this.problemMap=containers.Map();
            this.resourceFcnList={'aviread','load','fopen','imread','iminfo',...
            'importdata','iminfo','xlsread','dlmread','matfile',...
            'uiimport','cdfinfo','mmfileinfo','wavread','wavinfo'};

            this.resExtMap=containers.Map('load','mat');
            this.resourceList={};
            this.depStruct=this.readDependencies(this.fNameWithPath,whiteListPath,blackListPath,checkFileNameMismatch,checkFncHandles);
        end




        function[depFilePaths]=CollectDepFcnRes(this,depFcnNames,blackListPath)
            depFilePaths=cell(0,0);
            for ii=1:length(depFcnNames)
                tempCellArr=cell(size(this.depFuncNames));
                tempCellArr(:)=depFcnNames(ii);
                isAlreadyDepFunc=any(strcmp(this.depFuncNames,tempCellArr));
                if(isAlreadyDepFunc)
                    continue;
                end

                depFilePath=coder.internal.Helper.which(depFcnNames{ii});
                [pathstr,name,ext]=fileparts(depFilePath);
                if(~isempty(pathstr))
                    isNotInBlackListPath=~contains(pathstr,blackListPath);
                    if(isNotInBlackListPath)


                        isClassConstructor=coder.internal.MTREEUtils.isclass(depFilePath);
                        if isClassConstructor
                            this.depFuncNames=[this.depFuncNames(:)',{name}];
                            depFilePaths=[depFilePaths(:)',{fullfile(pathstr,[name,ext])}];
                        end
                    end
                end
            end
            this.depFunPaths=[this.depFunPaths(:)',depFilePaths(:)'];
        end

        function depFilePaths=getDepFcnFilePaths(this,fileMTree,blackListPath,fileName,funcNameWithPath)
            subFcnNames=coder.internal.DependencyContainer.getSubFcnNames(fileMTree);
            calls=mtfind(fileMTree,'Kind',{'CALL','DCALL'});

            depFcnNames=strings(Left(calls));

            depFcnNames=setdiff(depFcnNames,subFcnNames,'stable');
            if~isempty(this.checkFunctionCallFor)&&~this.foundCallToDesign
                this.foundCallToDesign=~isempty(cell2mat(regexp(depFcnNames,['^',this.checkFunctionCallFor,'$'])));
                if this.foundCallToDesign
                    this.designCallerFileName=fileName;
                    this.designCallerFilePath=funcNameWithPath;
                end
            end


            depFilePaths=this.CollectDepFcnRes(depFcnNames,blackListPath);
        end




        function resourcePaths=getResFilePaths(this,fileMTree,whiteListPath)
            callNodeList=mtfind(fileMTree,'Kind',{'CALL','DCALL'});
            resourcePaths=cell(0,0);
            indices=callNodeList.indices;

            for ii=1:length(indices)
                callNode=callNodeList.select(indices(ii));
                callee=callNode.Left.string;

                if(any(ismember(this.resourceFcnList,callNode.Left.string)))
                    if(callNode.Right.iskind('CHARVECTOR'))
                        resName=callNode.Right.string;
                        [firstIn]=regexpi(resName,'^''.*''$');

                        if(1==length(firstIn)&&1==firstIn(1))
                            resName=resName(2:end-1);
                        end





                        resFilePath=coder.internal.Helper.which([resName,'.']);


                        if(isempty(resFilePath))
                            if(this.resExtMap.isKey(callee))
                                defaultExt=this.resExtMap(callee);
                                resFilePath=coder.internal.Helper.which([resName,'.',defaultExt]);
                            end

                            if(isempty(resFilePath))
                                resFilePath=coder.internal.Helper.which([resName,'.']);
                            end
                        end

                        if(~isempty(resFilePath))
                            [pathstr,name,ext]=fileparts(resFilePath);

                            if strcmp(pathstr,whiteListPath)
                                resFilePath=fullfile(whiteListPath,[name,ext]);
                                resourcePaths=[resourcePaths(:)',{resFilePath}];
                                this.resourceList=[this.resourceList(:)',{resFilePath}];
                            end
                        end
                    end
                end
            end
        end

        function tmpDepStruct=readDependencies(this,funcNameWithPath,whiteListPath,blackListPath,checkFileNameMismatch,checkFncHandles)
            fileMTree=mtree(fileread(funcNameWithPath));
            [~,fileName,~]=fileparts(funcNameWithPath);

            if(checkFileNameMismatch)
                coder.internal.DependencyContainer.checkFuncNameMismatch(fileMTree,fileName);
            end

            if(checkFncHandles)
                coder.internal.DependencyContainer.checkForFunctionHandles(funcNameWithPath,fileMTree);
            end

            depFilePaths=this.getDepFcnFilePaths(fileMTree,blackListPath,fileName,funcNameWithPath);
            resourcePaths=this.getResFilePaths(fileMTree,whiteListPath);




            tmpDepStruct.filePath=funcNameWithPath;
            tmpDepStruct.depends=[];
            tmpDepStruct.resourcePaths=resourcePaths;
            for ii=1:length(depFilePaths)
                tmpDepStruct.depends=[tmpDepStruct.depends,this.readDependencies(depFilePaths{ii},whiteListPath,blackListPath,checkFileNameMismatch,checkFncHandles)];
            end
        end

        function pp(this,depStruct,level)
            tabs=ones(1,level);
            seperator=9;
            tabs(:)=seperator;
            if(~isempty(depStruct))
                [~,fileName,mExt]=fileparts(depStruct.filePath);
                fprintf(1,'%s+ %s\n',tabs,['<a href="matlab:edit(''',depStruct.filePath,''')">',fileName,mExt,'</a>']);

                for ii=1:length(depStruct.resourcePaths)
                    [~,fileName,mExt]=fileparts(depStruct.resourcePaths{ii});
                    fprintf(1,'%s* %s\n',[tabs,seperator],['<a href="matlab:edit(''',depStruct.resourcePaths{ii},''')">',fileName,mExt,'</a>']);
                end

                if(0<length(depStruct.depends))
                    for ii=1:length(depStruct.depends)
                        this.pp(depStruct.depends(ii),level+1);
                    end
                end
            else
                disp(message('Coder:FxpConvDisp:FXPCONVDISP:dependStructEmpty').getString);
            end
        end
    end



    methods(Static)

        function subFcnNames=getSubFcnNames(fileMTree)
            subTF=mtfind(fileMTree,'Kind','FUNCTION');
            subFcnNames=cell(0,0);
            if(~isnull(subTF))
                indices=subTF.indices;
                if(1<=length(indices))


                    for ii=1:length(indices)
                        fcnNode=subTF.select(indices(ii));
                        subFcnNames=[subFcnNames(:)',{fcnNode.Fname.string}];
                    end
                end
            end
        end

        function checkFuncNameMismatch(fileMTree,fileName)

            subTF=mtfind(fileMTree,'Kind','FUNCTION');

            if(~isnull(subTF))
                indices=subTF.indices;
                FcnIndex=indices(1);
                FcnNode=subTF.select(FcnIndex);

                [actualFcnName,mismatch]=coder.internal.DependencyContainer.isFuncNameMismatch(FcnNode,fileName);
                if(mismatch)
                    error(message('Coder:FXPCONV:topFcnNameMismatch',...
                    actualFcnName,fileName));
                end
            end
        end

        function[actualFcnName,mismatch]=isFuncNameMismatch(FcnNode,fileName)
            actualFcnName=FcnNode.Fname.string;
            mismatch=~strcmp(actualFcnName,fileName);
        end

        function checkForFunctionHandles(filePath,fileMTree)
            fcnHndlNodes=mtfind(fileMTree,'Kind','AT');
            if(~isnull(fcnHndlNodes))
                if this.doubleToSingle
                    error(message('Coder:FXPCONV:unsupportedFcnHndl_DTS',coder.internal.Helper.getPrintLinkStr(filePath,fcnHndlNodes,2)));
                else
                    error(message('Coder:FXPCONV:unsupportedFcnHndl',coder.internal.Helper.getPrintLinkStr(filePath,fcnHndlNodes,2)));
                end
            end
        end
    end

    methods(Static)

        function printFileDependency(tbDepConts)
            arrayfun(@closure,tbDepConts);
            function closure(depCont)
                fprintf(1,'Printing file dependency tree for %s\n',depCont.fName);
                depCont.prettyPrint();
            end
        end
    end
    methods(Access=public)



        function this=DependencyContainer(funcNameWithPath,whiteListPath,options,doubleToSingle)
            if nargin<4
                doubleToSingle=false;
            end
            this.doubleToSingle=doubleToSingle;
            this.fNameWithPath=funcNameWithPath;
            [~,this.fName,~]=fileparts(funcNameWithPath);
            blackListPath=fullfile(matlabroot,'toolbox');
            fcnCallToSearch=[];
            if(~isempty(options)&&isstruct(options))
                if(isfield(options,'checkFileNameMismatch'))
                    checkFileNameMismatch=options.checkFileNameMismatch;
                end
                if(isfield(options,'checkFncHandles'))
                    checkFncHandles=options.checkFncHandles;
                end
                if(isfield(options,'blackListPath'))
                    blackListPath=options.blackListPath;
                end
                if(isfield(options,'checkFunctionCallFor'))
                    fcnCallToSearch=options.checkFunctionCallFor;
                end
            else
                checkFileNameMismatch=false;
                checkFncHandles=false;
            end
            this.checkFunctionCallFor=fcnCallToSearch;
            this.foundCallToDesign=false;
            this.designCallerFileName='';
            this.designCallerFilePath='';
            this.initMembers(whiteListPath,blackListPath,checkFileNameMismatch,checkFncHandles)
        end

        function prettyPrint(this)
            this.pp(this.depStruct,1);
        end

        function[depFilePaths]=getDependentFunctionFiles(this)
            depFilePaths=this.depFunPaths;
        end
    end
end
