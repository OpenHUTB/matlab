


classdef WorkspaceObjectFinder











    properties(GetAccess=public,SetAccess=private)
        modelName='';
        specifiedclassName='';
        hModelWks=[];
    end

    properties(GetAccess=public,SetAccess=public)
        filterOutShadowedVars=false;
    end

    methods(Access=public)

        function obj=WorkspaceObjectFinder(modelName,className)
            obj.modelName=modelName;
            if isempty(className)||~ischar(className)
                DAStudio.error('SimulinkFixedPoint:autoscaling:invalidClassName');
            end
            obj.specifiedclassName=className;
            if~isempty(modelName)
                if~ischar(modelName)
                    DAStudio.error('SimulinkFixedPoint:autoscaling:mustBeString','modelName');
                end
                if bdIsLoaded(modelName)
                    obj.hModelWks=get_param(modelName,'modelworkspace');
                else
                    DAStudio.error('Simulink:Commands:BlockDiagramNotLoaded',modelName);
                end
            end
        end

        function nameList=getNameListFromModelWks(this)
            nameList={};
            if~isempty(this.hModelWks)
                wks=this.hModelWks;
                varList=wks.whos;
                nameList=selectVarNamesForSpecifiedClass(this,varList);
            end
        end

        function nameList=getNameListFromGlobalWks(this)

            if~isempty(this.modelName)
                dataSource=Simulink.data.DataSource.create(this.modelName);
            else
                dataSource=Simulink.data.BaseWorkspace;
            end
            nameList=dataSource.whos(this.specifiedclassName);
            if this.filterOutShadowedVars
                nameList=this.removeShadowedByMdlWorkspace(nameList);
            end
        end

    end

    methods(Access=private)

        function selectedNameList=selectVarNamesForSpecifiedClass(this,varList)
            selectedNameList={};
            if~isempty(varList)
                [classNames{1:length(varList)}]=deal(varList.class);
                indices=find(cellfun(@this.isaSpecifiedClass,classNames));
                if~isempty(indices)
                    releventVarList=varList(indices);
                    [selectedNameList{1:length(releventVarList)}]=deal(releventVarList.name);
                end
            end
        end

        function isSpecCls=isaSpecifiedClass(this,className)
            isSpecCls=strcmp(className,this.specifiedclassName)||...
            (~isempty(meta.class.fromName(className))&&...
            (meta.class.fromName(className)<meta.class.fromName(this.specifiedclassName)));





        end

        function unshadowedNameList=removeShadowedByMdlWorkspace(this,nameList)

            unshadowedNameList=nameList;


            if~isempty(this.hModelWks)
                varList=this.hModelWks.whos;
                if~isempty(varList)
                    [modelVarNames{1:length(varList)}]=deal(varList.name);
                    dummyVal(1:length(modelVarNames))=true;
                    modelVarSet=containers.Map(modelVarNames,dummyVal);
                    unshadowedCount=0;
                    for i=1:length(nameList)
                        if~modelVarSet.isKey(nameList{i})
                            unshadowedCount=unshadowedCount+1;
                            unshadowedNameList{unshadowedCount}=nameList{i};
                        end
                    end

                    unshadowedNameList=...
                    unshadowedNameList(1:unshadowedCount);
                end
            end
        end


    end



end


