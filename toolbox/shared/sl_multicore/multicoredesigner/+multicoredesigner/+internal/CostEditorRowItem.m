classdef CostEditorRowItem<handle





    properties
ColumnNames
Block
BlockPath
Cost
ComputedCost
UserCost
OrigCost
Auto
Ratio
SourceObj
RegionId
IsSim
        ClassPropertyNames={'Block','Auto','Cost','Ratio'};
    end

    methods


        function obj=CostEditorRowItem(srcObj,regionId,blockPath,cost,...
            userCost,overrideCostData,isSim)

            obj.BlockPath=blockPath;
            relativePath=split(blockPath,'/');
            if length(relativePath)>1

                relativePath(1)=[];
            end
            obj.Block=strjoin(relativePath,'/');
            obj.ComputedCost=cost;
            obj.Ratio=cost;
            obj.SourceObj=srcObj;
            obj.ColumnNames=getColumns(srcObj);
            obj.RegionId=regionId;
            obj.IsSim=isSim;
            userCost=double(userCost)/1e3;
            if userCost>=1
                roundedUserCost=floor(userCost);
            else
                roundedUserCost=userCost;
            end
            if cost==intmax('uint64')
                roundedCost=cost;
            else
                cost=double(cost)/1e3;
                if cost>=1
                    roundedCost=floor(cost);
                else
                    roundedCost=cost;
                end
            end
            obj.UserCost=num2str(roundedUserCost);
            if overrideCostData
                obj.Auto='0';
                obj.Cost=num2str(roundedUserCost);
                obj.OrigCost=num2str(userCost);
            else
                obj.Auto='1';
                obj.Cost=num2str(roundedCost);
                obj.OrigCost=num2str(cost);
            end

        end

        function propValue=getPropValue(obj,propName)
            classPropName=getClassPropName(obj,propName);
            propValue=obj.(classPropName);
            if(uint64(str2double(propValue))==intmax('uint64'))
                propValue='';
            end
        end

        function setPropValue(obj,propName,newVal)
            classPropName=getClassPropName(obj,propName);

            modelName=getModelName(obj.SourceObj.MappingData,obj.RegionId);
            mfModel=get_param(modelName,'MulticoreDataModel');
            mc=slmulticore.MulticoreConfig.getMulticoreConfig(mfModel);
            blksArray=mc.blocks.toArray;
            idx=find(strcmp({blksArray.path},obj.BlockPath));

            if strcmp(classPropName,'Cost')
                dval=str2double(newVal);
                if(isnan(dval)||dval<0||...
                    uint64(dval)>intmax('int64')*1e-3)
                    dp=DAStudio.DialogProvider;
                    msg=DAStudio.message('dataflow:Spreadsheet:InvalidCostValue');
                    title=DAStudio.message('dataflow:Spreadsheet:CostEditorCostColumnName');
                    dp.errordlg(msg,title,true);
                else
                    obj.UserCost=newVal;
                    blks=mc.blocks(idx);
                    for i=1:length(blks)
                        blks(i).userCost=dval*1e3;
                    end
                    obj.Cost=newVal;
                    updateAllRows(obj.SourceObj);
                end
            elseif strcmp(classPropName,'Auto')
                isAuto=logical(newVal-'0');
                blks=mc.blocks(idx);
                for i=1:length(blks)
                    blks(i).allowUserCost=not(isAuto);
                end
                if isAuto
                    obj.Cost=obj.ComputedCost;
                else
                    obj.Cost=obj.UserCost;
                end
                obj.Auto=newVal;
                updateAllRows(obj.SourceObj);
            end
        end

        function isHyperlink=propertyHyperlink(obj,propName,clicked)
            classPropName=getClassPropName(obj,propName);
            isHyperlink=false;

            if strcmp(classPropName,'Block')&&...
                ~isempty(obj.BlockPath)&&...
                getSimulinkBlockHandle(obj.BlockPath)~=-1
                isHyperlink=true;
                if clicked
                    removeAllHighlighting(obj.SourceObj.UIObj);
                    modelName=getModelName(obj.SourceObj.MappingData,obj.RegionId);
                    set_param(modelName,'HiliteAncestors','off');

                    modelPath=getModelPath(obj.SourceObj.MappingData,obj.RegionId);
                    bp=Simulink.BlockPath([modelPath,{obj.BlockPath}]);
                    hilite_system(bp);
                    set_param(obj.BlockPath,'Selected','on');
                end
            end
        end


        function aPropType=getPropDataType(obj,propName)
            classPropName=getClassPropName(obj,propName);
            aPropType='string';
            if strcmp(classPropName,'Auto')
                aPropType='bool';
            end
        end


        function getPropertyStyle(obj,propName,propertyStyle)
            classPropName=getClassPropName(obj,propName);
            if strcmp(obj.Block,'Subsystem')
                propertyStyle.WidgetInfo=struct('Type','hyperlink','WidgetAlignment','left',...
                'Values','',...
                'Colors',[[0.8,0.8,0.8,1],[1.0,1.0,0.9,1]]);
                return
            end
            if~strcmp(classPropName,'Ratio')&&~strcmp(classPropName,'Cost')
                return
            end
            if strcmp(classPropName,'Cost')&&(uint64(str2double(obj.Cost))==intmax('uint64'))
                propertyStyle.Icon=fullfile(matlabroot,'toolbox/shared/dastudio/resources/warning_16.png');
                propertyStyle.IconAlignment='right';
                propertyStyle.Tooltip=DAStudio.message('dataflow:Spreadsheet:CostNotAvailableTooltip');
                return
            else
                if getCostMethod(obj.SourceObj.MappingData)==slmulticore.CostMethod.Profiling
                    propertyStyle.Tooltip=DAStudio.message('dataflow:Spreadsheet:ProfiledCostTooltip',obj.OrigCost);
                else
                    propertyStyle.Tooltip=DAStudio.message('dataflow:Spreadsheet:CostTooltip',obj.OrigCost);
                end
            end

            if strcmp(classPropName,'Ratio')&&str2double(obj.Cost)>=0
                maxCost=getMaxGroupCost(obj.SourceObj,obj.RegionId);
                if maxCost==0
                    relativeCost=0;
                else
                    relativeCost=ceil(100*(str2double(obj.OrigCost)/maxCost));
                end
                if(relativeCost>100)
                    relativeCost=100;
                end
                propertyStyle.WidgetInfo=struct('Type','progressbar','WidgetAlignment','left',...
                'Values',double([relativeCost,100-relativeCost]),...
                'Colors',[[0.8,0.8,0.8,1],[1.0,1.0,1.0,1]]);
                if relativeCost==100
                    propertyStyle.Tooltip=DAStudio.message('dataflow:Spreadsheet:HighestRelativeLoadTooltip');
                else
                    propertyStyle.Tooltip=DAStudio.message('dataflow:Spreadsheet:RelativeLoadTooltip',relativeCost);
                end
            end
        end


        function tf=isValidProperty(obj,propName)
            tf=true;
            if strcmp(obj.Block,'Subsystem')&&~strcmp(propName,'Block')
                tf=false;
            end
        end

        function tf=isDragAllowed(~)
            tf=true;
        end

        function isReadOnly=isReadonlyProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);

            isReadOnly=obj.IsSim||~(strcmp(classPropName,'Auto')||...
            (strcmp(classPropName,'Cost')&&strcmp(obj.Auto,'0')));
        end

        function isEditable=isEditableProperty(obj,propName)
            classPropName=getClassPropName(obj,propName);

            isEditable=strcmp(classPropName,'Auto')||...
            (strcmp(classPropName,'Cost')&&strcmp(obj.Auto,'0'));
        end


        function isHier=isHierarchical(~)
            isHier=false;
        end
    end

    methods(Access=private)
        function classPropName=getClassPropName(obj,propName)
            idx=find(strcmp(getColumns(obj.SourceObj),propName),1);
            classPropName=obj.ClassPropertyNames{idx};
        end
    end
end


