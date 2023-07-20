
classdef InstParamSpreadsheet<handle
    properties
m_DlgSource
m_blockHandle
m_Arguments
m_Data
m_SlimDialog
m_DefaultValue
m_DefaultValueInstSpec
    end

    properties(SetAccess=private,GetAccess=private)
m_DefaultValueInternal
m_SpreadsheetChanged
    end

    methods
        function obj=InstParamSpreadsheet(src,isSlimDialog)
            obj.m_DlgSource=src;
            obj.m_blockHandle=src.getBlock().Handle;
            obj.getArguments();
            obj.m_Data=[];
            obj.m_SlimDialog=isSlimDialog;
            obj.getDefaultValues();
            obj.m_DlgSource.UserData.HierarchySpreadsheetContextMenu=[];


            obj.m_SpreadsheetChanged=true;
        end

        function children=getChildren(this)
            if~isempty(this.m_Data)
                children=this.m_Data;
                return;
            else
                this.m_DlgSource.UserData.spreadsheetData=[];
                children=this.createChildren();
                this.m_Data=children;
            end
        end


        function showPromotedModelArgumentDialog(this)
            if~this.m_SpreadsheetChanged
                return;
            end

            this.m_SpreadsheetChanged=false;
            try
                Simulink.ModelReference.internal.showPromotedModelArgumentDialog;
            catch
            end
        end


        function onSpreadsheetChanged(this,~,~,~,~)
            this.m_SpreadsheetChanged=true;
        end


        function found=findAndUpdateChild(this,sidPath,propName,propValue)
            found=false;
            for i=1:length(this.m_Data)
                found=this.m_Data(i).findAndUpdateInHierarchy(...
                sidPath,propName,propValue);
                if found
                    return;
                end
            end
        end
    end

    methods(Access=private)
        function getArguments(this)
            instParams=get_param(this.m_blockHandle,'InstanceParametersInfo');
            for instParamIdx=1:length(instParams)
                instParam=instParams(instParamIdx);
                this.m_Arguments(instParamIdx).Name=instParam.Name;
                this.m_Arguments(instParamIdx).Value=instParam.Value;

                if instParam.Argument
                    this.m_Arguments(instParamIdx).InstanceSpecific='on';
                else
                    this.m_Arguments(instParamIdx).InstanceSpecific='off';
                end

                if isempty(instParam.Path)
                    this.m_Arguments(instParamIdx).Path={};
                    this.m_Arguments(instParamIdx).RealPath={};
                else
                    this.m_Arguments(instParamIdx).Path=instParam.Path;
                    this.m_Arguments(instParamIdx).RealPath=instParam.Path;
                end

                this.m_Arguments(instParamIdx).IsProtected=instParam.IsFromProtectedModel;
                this.m_Arguments(instParamIdx).IsFromProtectedModel=instParam.IsFromProtectedModel;
                this.m_Arguments(instParamIdx).ParameterCreatedFrom=instParam.ParameterCreatedFrom;
                this.m_Arguments(instParamIdx).SIDPath=instParam.SIDPath;
            end
        end

        function getDefaultValues(this)




            this.m_DefaultValue=DAStudio.message('Simulink:modelReference:ModelArgDefaultUIValue');
            this.m_DefaultValueInstSpec=DAStudio.message('Simulink:modelReference:ModelArgDefaultUIValue_InstanceSpecific');
            this.m_DefaultValueInternal=DAStudio.message('Simulink:modelReference:ModelArgDefaultInternalValue');

        end


        function c=createChildren(this)
            modelName=get_param(this.m_blockHandle,'CosimulationTargetName');
            modelBlkName=get_param(this.m_blockHandle,'Name');
            previousLevel=[modelName,'/',modelBlkName];
            accumulatedBlockPath={};

            tempRoot=Simulink.cosimblock.internal.InstParamSpreadsheetRow(this.m_DlgSource,previousLevel,this.m_SlimDialog,accumulatedBlockPath);

            this.generateChildrenForNode(tempRoot,this.m_Arguments,modelName,accumulatedBlockPath);
            c=tempRoot.m_Children;
        end

        function generateChildrenForNode(this,node,parameters,sourceName,accumulatedBlockPath)

            modelAndBlockNames=strsplit(sourceName,'/');
            modelName=modelAndBlockNames(1,1);
            modelName=modelName{:};

            [forThisNode,forSubNode]=this.DivideParameters(parameters);

            for idx=1:length(forThisNode)
                curParameter=forThisNode(1,idx);

                node.m_Children=[node.m_Children...
                ,Simulink.cosimblock.internal.InstParamSpreadsheetRow(...
                this.m_DlgSource,...
                sourceName,...
                this.m_SlimDialog,...
                curParameter.RealPath,...
                curParameter.Name,...
                this.m_DefaultValue,...
                this.m_DefaultValueInstSpec,...
                this.m_DefaultValueInternal,...
                modelName,...
                curParameter.Value,...
                curParameter.InstanceSpecific,...
                curParameter.SIDPath,...
                curParameter.IsFromProtectedModel,...
                curParameter.ParameterCreatedFrom)];
            end
            this.m_DlgSource.UserData.spreadsheetData=[this.m_DlgSource.UserData.spreadsheetData,node.m_Children];

            parameterCells=this.CategorizeParameters(forSubNode);


            for idx=1:length(parameterCells)
                curParameters=parameterCells{idx};

                [subParameters,firstPath]=this.DepricateFirstLevelPath(curParameters);
                combinedPath={accumulatedBlockPath{:},firstPath{:}};


                node.m_Children=[node.m_Children...
                ,Simulink.cosimblock.internal.InstParamSpreadsheetRow(this.m_DlgSource,firstPath{:},this.m_SlimDialog,combinedPath)];
                this.generateChildrenForNode(node.m_Children(end),subParameters,firstPath{:},combinedPath);
            end
        end


        function[forThisNode,forSubNode]=DivideParameters(~,parameters)
            forThisNode=[];
            forSubNode=[];
            for paramIdx=1:length(parameters)
                if isempty(parameters(paramIdx).Path)
                    forThisNode=[forThisNode,parameters(paramIdx)];
                else
                    forSubNode=[forSubNode,parameters(paramIdx)];
                end
            end
        end


        function[subParameters,firstPath]=DepricateFirstLevelPath(~,parameters)
            subParameters=parameters;
            for idx=1:length(parameters)
                curParam=parameters(idx);
                paths=curParam.Path;
                firstPath=paths(1);
                paths=paths(2:end);
                if isempty(paths)
                    paths={};
                end
                subParameters(idx).Path=paths;
            end
        end


        function parameterCells=CategorizeParameters(~,parameters)
            paths=arrayfun(@(obj)obj.Path,parameters,'UniformOutput',false);
            objMap=containers.Map;
            myCat=1;
            parameterCells={};
            for ii=1:length(paths)
                curPath=paths(ii);
                curPath=curPath{:};
                curPath=curPath(1);
                curPath=curPath{:};
                if~isKey(objMap,curPath)
                    objMap(curPath)=myCat;
                    parameterCells{end+1}=parameters(ii);%#ok
                    myCat=myCat+1;
                else
                    parameterCells{objMap(curPath)}=[parameterCells{objMap(curPath)},parameters(ii)];%#ok
                end
            end
        end
    end
end


