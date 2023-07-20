classdef ParameterObjectInfoCollector<handle

































    properties(GetAccess=protected,SetAccess=private)
        sudPath='';
        modelPath='';
        hModelWks=[];
        pObjInfo=containers.Map();
        wksObjFinder=[];
        variableUsageParser=SimulinkFixedPoint.SimulinkVariableUsageParser.getParserForDataObjects();
    end

    methods
        function obj=ParameterObjectInfoCollector(sudPath)
            obj.sudPath=sudPath;
            obj.modelPath=bdroot(sudPath);
            obj.hModelWks=get_param(obj.modelPath,'modelworkspace');
            obj.wksObjFinder=...
            SimulinkFixedPoint.AutoscalerUtils.WorkspaceObjectFinder(...
            obj.modelPath,'Simulink.Parameter');
            obj.wksObjFinder.filterOutShadowedVars=true;
            obj.pObjInfo=containers.Map();
            obj.addPObjInfoFromModelWorkspace();
            obj.addPObjInfoFromBaseWorkspace();
        end

        function pObjInfo=getParameterObjectInfo(this)
            pObjInfo=this.pObjInfo.values;
        end

        function assocRecs=getAssocParamRequiringUpdate(this)
            paramObjNames=this.pObjInfo.keys;
            L=length(paramObjNames);
            assocRecs={};
            for i=1:L
                pinfo=this.pObjInfo(paramObjNames{i});
                clientAssocRecs=this.getAssocRecForClientBlocks(pinfo);
                assocRecs=[assocRecs,clientAssocRecs{:}];%#ok<AGROW>
            end
        end
    end

    methods(Access=private)
        function addPObjInfoFromModelWorkspace(this)
            pObjNameList=this.wksObjFinder.getNameListFromModelWks();
            sourceType='model workspace';
            setPObjInfo(this,pObjNameList,sourceType);
        end

        function addPObjInfoFromBaseWorkspace(this)
            pObjNameList=this.wksObjFinder.getNameListFromGlobalWks();
            if isempty(get_param(this.modelPath,'DataDictionary'))
                sourceType='base workspace';
            else
                sourceType='data dictionary';
            end
            setPObjInfo(this,pObjNameList,sourceType);
        end

        function setPObjInfo(this,pObjNameList,sourceType)
            for iVariable=1:numel(pObjNameList)
                variableName=pObjNameList{iVariable};
                users=getValidUsers(this.variableUsageParser,this.sudPath,variableName,...
                'SearchMethod','cached','SourceType',sourceType);
                if~isempty(users)
                    processPObjVarUse(this,variableName,users);
                end
            end
        end

        function processPObjVarUse(this,variableName,users)

            pObj=slResolve(variableName,this.modelPath,'variable');

            varUseStruct=struct('Name',variableName,'Users',{users});


            [minValue,maxValue]=this.determineRange(pObj,varUseStruct);


            info=struct('Name',variableName,'object',pObj,...
            'usage',varUseStruct,'min',minValue,'max',maxValue);


            this.pObjInfo(variableName)=info;
        end

        function[minValue,maxValue]=determineRange(this,pObj,varUsage)
            minValue=pObj.Min;
            maxValue=pObj.Max;


            L=length(varUsage.Users);
            for i=1:L
                srcBlk=varUsage.Users{i};
                [clMin,clMax]=this.getDesignMinMaxOfClientBlk(srcBlk,varUsage.Name);
                minValue=min(SimulinkFixedPoint.AutoscalerUtils.unionRange(minValue,clMin));
                maxValue=max(SimulinkFixedPoint.AutoscalerUtils.unionRange(maxValue,clMax));
            end
        end

        function[dmin,dmax]=getDesignMinMaxOfClientBlk(~,srcBlk,pObjName)
            dmin=[];
            dmax=[];
            ea=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface().getAutoscaler(srcBlk);
            pathItems=ea.getPathItems(srcBlk);
            for pItemIdx=1:length(pathItems)
                [isForBlkParam,blkParamName]=ea.isPathItemForBlockParam(srcBlk,pathItems{pItemIdx});
                if isForBlkParam


                    unevaledParamStr=get_param(srcBlk.handle,blkParamName);

                    if strcmp(unevaledParamStr,pObjName)









                        [dmin,dmax]=ea.gatherDesignMinMax(srcBlk,pathItems{pItemIdx});
                    end
                end
            end
        end

        function updatedAssocRecs=getAssocRecForClientBlocks(this,pinfo)
            updatedAssocRecs={};
            varUsage=pinfo.usage;
            L=length(varUsage.Users);
            for i=1:L
                srcBlk=varUsage.Users{i};
                ea=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface().getAutoscaler(srcBlk);

                blkAssocRecs=ea.gatherAssociatedParam(srcBlk);
                for recIdx=1:length(blkAssocRecs)
                    if isfield(blkAssocRecs(recIdx),'paramObj')&&...
                        ~isempty(blkAssocRecs(recIdx).paramObj)&&...
                        (pinfo.object==blkAssocRecs(recIdx).paramObj)

                        blkAssocRecs(recIdx)=...
                        this.updateMinMaxVal(blkAssocRecs(recIdx),'Min',pinfo.min);
                        blkAssocRecs(recIdx)=...
                        this.updateMinMaxVal(blkAssocRecs(recIdx),'Max',pinfo.max);
                        updatedAssocRecs=[updatedAssocRecs,blkAssocRecs(recIdx)];%#ok<AGROW>
                    end
                end
            end
        end

        function assocRec=updateMinMaxVal(~,assocRec,strEnding,val)
            fNames=fieldnames(assocRec);
            fieldMatch=regexp(fNames,[strEnding,'$']);
            idx=find(cellfun(@(x)~isempty(x),fieldMatch));
            releventFieldName=fNames{idx(1,1)};
            assocRec.(releventFieldName)=val;
        end
    end
end


