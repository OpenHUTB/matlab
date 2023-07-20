


classdef FiTemplateManager<handle

    properties
fcnMtreeMap
fcnDependencyMap

templatePath
userTemplatePath


functionsUsed
    end

    methods
        function this=FiTemplateManager(templatePath)
            this.templatePath=templatePath;
            this.userTemplatePath='';

            this.fcnMtreeMap=containers.Map();
            this.fcnDependencyMap=containers.Map();
        end
    end


    methods
        function beginSession(this,userTemplatePath)
            this.functionsUsed=containers.Map();
            this.userTemplatePath=userTemplatePath;
        end

        function useFunction(this,functionName)
            try
                functionName=strtok(functionName,',');
                fcnTree=this.getFunctionMTree(functionName);
            catch ex
                if(strcmp(ex.identifier,'Coder:FXPCONV:BADFILENAME'))
                    error(message('Coder:FXPCONV:BADREPLACEMENTFILENAME',functionName));
                else
                    rethrow(ex);
                end
            end
            if this.functionsUsed.isKey(functionName)

                return;
            end
            this.functionsUsed(functionName)=fcnTree;

            dependencies=this.getFunctionDependencies(functionName);
            for i=1:length(dependencies)
                callee=dependencies{i};
                this.useFunction(callee);
            end
        end






        function code=getLibraryCode(this,fcnUsed)
            code='';
            indentLevel=0;
            printSubTrees=false;
            if nargin<2
                fcnHndl=@this.getNonTbxOrTemplateFcnsUsed;
                fcns=this.withFcnTemplateInPath(fcnHndl);

                for i=1:length(fcns)
                    fcn=fcns{i};
                    fcnCode=fcn.tree2str(indentLevel,printSubTrees,{});
                    code=[code,char(10),char(10),fcnCode];%#ok<AGROW>
                end
            else
                assert(any(ismember(this.functionsUsed.keys,fcnUsed)));
                fcnPath=coder.internal.Helper.which(fcnUsed);
                isToolBoxPath=coder.internal.Helper.isToolboxPath(fcnPath);
                isInTemplateFolder=this.isInTemplateFolder(fcnPath);
                assert(~isToolBoxPath||isInTemplateFolder);

                code=this.functionsUsed(fcnUsed).tree2str(indentLevel,printSubTrees,{});
            end
        end

        function fcnsUsed=getReplacementFcnsUsed(this)
            fcnsUsed={};
            fcns=this.functionsUsed.keys;
            for ii=1:length(fcns)
                fcn=fcns{ii};
                fcnPath=coder.internal.Helper.which(fcn);
                isToolBoxPath=coder.internal.Helper.isToolboxPath(fcnPath);
                isInTemplateFolder=this.isInTemplateFolder(fcnPath);
                if~isToolBoxPath||isInTemplateFolder
                    fcnsUsed={fcnsUsed{:},fcn};
                end
            end
        end

        function dependencies=getFunctionDependencies(this,functionName)
            if~this.fcnMtreeMap.isKey(functionName)
                this.loadFunctionMTree(functionName);
            end

            dependencies=this.fcnDependencyMap(functionName);
            dependencies=dependencies.keys();
        end
    end

    methods(Access='private')

        function fcnTrees=getNonTbxOrTemplateFcnsUsed(this)
            fcnTrees={};
            fcns=this.functionsUsed.keys;
            for ii=1:length(fcns)
                fcn=fcns{ii};
                fcnPath=coder.internal.Helper.which(fcn);
                isToolBoxPath=coder.internal.Helper.isToolboxPath(fcnPath);
                isInTemplateFolder=this.isInTemplateFolder(fcnPath);
                if~isToolBoxPath||isInTemplateFolder
                    fcnTrees={fcnTrees{:},this.functionsUsed(fcn)};
                end
            end
        end




        function output=withFcnTemplateInPath(this,fcnHdnlToCall)
            pathBak=path;
            addpath(this.templatePath);
            addpath(this.userTemplatePath);

            output=fcnHdnlToCall();


            c=onCleanup(@()path(pathBak));
        end

        function truthVal=isInTemplateFolder(this,givenPath)
            truthVal=false;

            tempPath=this.templatePath;
            if strcmp(filesep,'\')
                tempPath=strrep(tempPath,'\','\\');
            end
            if(~isempty(regexp(givenPath,tempPath,'once')))
                truthVal=true;
            end
        end

        function loadDependencies(this,fcnName,fcnNode,functionScriptPath)

            fcnNodeList=fcnNode.subtree;
            callNodes=mtfind(fcnNodeList,'Kind','CALL');
            cindices=callNodes.indices;


            dcallNodes=mtfind(fcnNodeList,'Kind','DCALL');
            dindices=dcallNodes.indices;

            indices=sort([cindices,dindices]);

            this.fcnDependencyMap(fcnName)=containers.Map();
            fcnDependencies=this.fcnDependencyMap(fcnName);

            for i=1:length(indices)
                index=indices(i);
                callNode=callNodes.select(index);
                callee=callNode.Left.string;

                whichCmd=sprintf('calleeFilePath = which(''%s'', ''%s'', ''%s'');',callee,'in',functionScriptPath);
                evalc(whichCmd);

                if~isempty(strfind(calleeFilePath,'built-in'))
                    continue;
                end

                calleePath=fileparts(calleeFilePath);
                if~strcmp(this.templatePath,calleePath)

                    continue;
                end




                this.loadFunctionMTree(callee);


                fcnDependencies(callee)=true;
            end
        end

        function loadFunctionMTree(this,functionName)


            pathBak=path;
            addpath(this.templatePath);
            addpath(this.userTemplatePath);


            c=onCleanup(@()path(pathBak));


            try
                [~]=which(this.templatePath);
            catch me %#ok<NASGU>
            end

            fileWithPath=[];
            possiblePaths={this.userTemplatePath,this.templatePath};
            for i=1:length(possiblePaths)
                aPath=possiblePaths{i};
                functionPath=fullfile(aPath,[functionName,'.m']);

                fileWithPath=coder.internal.Helper.which(functionPath);
                if~isempty(fileWithPath)
                    break;
                end
            end

            if isempty(fileWithPath)
                error(message('Coder:FXPCONV:BADFILENAME',functionName));
            end

            code=fileread(fileWithPath);
            tree=mtree(code,'-comments');

            fcns=mtfind(tree,'Kind','FUNCTION');

            indices=fcns.indices;

            if(isempty(indices))
                error(message('Coder:FXPCONV:BADREPLACEMENTCODEFILE',functionName));
            end

            topFunction=fcns.select(indices(1));

            this.fcnMtreeMap(functionName)=topFunction;

            this.loadDependencies(functionName,topFunction,functionPath);
        end


        function fcnTree=getFunctionMTree(this,functionName)
            if~this.fcnMtreeMap.isKey(functionName)
                this.loadFunctionMTree(functionName);
            end
            fcnTree=this.fcnMtreeMap(functionName);
        end
    end
end

