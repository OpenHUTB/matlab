classdef HierarchicalView<handle





    properties
        name;
        sid;
        blockType;
        parent;
        children;
        cloneDetectionStatus;
        blockPathCategoryMap;
        colorCodes;
        blockFullPath;
        modelHierarchySSColumn1=DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn1');
        modelHierarchySSColumn2=DAStudio.message('sl_pir_cpp:creator:modelHierarchySSColumn2');
    end
    methods(Access=public)

        function this=HierarchicalView(name,sid,blockType,parent,children,...
            blockPathCategoryMap,cloneDetectionStatus,colorCodes,blockFullPath)
            if nargin>0
                this.name=name;
                this.sid=sid;
                this.blockType=blockType;
                this.parent=parent;
                this.children=children;
                this.cloneDetectionStatus=cloneDetectionStatus;
                this.blockPathCategoryMap=blockPathCategoryMap;
                this.colorCodes=colorCodes;
                this.blockFullPath=blockFullPath;
            end

        end

        function label=getDisplayLabel(this)
            label=this.name;
        end


        function fileName=getDisplayIcon(~)
            fileName='hidinghierarchyIcon.png';
        end


        function propValue=getPropValue(this,propName)

            assert(strcmp(propName,this.modelHierarchySSColumn1)||...
            strcmp(propName,this.modelHierarchySSColumn2),'Invalid Column name');
            propValue='';
            switch propName
            case this.modelHierarchySSColumn1
                propValue=this.name;
            case this.modelHierarchySSColumn2
                if this.cloneDetectionStatus&&~isempty(this.blockPathCategoryMap)
                    if isKey(this.blockPathCategoryMap,this.blockFullPath)
                        cloneGroupName=this.blockPathCategoryMap(char(this.blockFullPath)).CloneGroupName;
                        propValue=cloneGroupName;
                    end
                end
            end
        end

        function isHyperlink=propertyHyperlink(this,propName,clicked)
            isHyperlink=false;
            if strcmp(propName,this.modelHierarchySSColumn1)&&~strcmp(this.blockType,'Model')
                isHyperlink=true;
            end
            if clicked
                load_system(this.parent);
                allSys=find_system('SearchDepth',0);
                for ii=1:length(allSys)
                    set_param(allSys{ii},'HiliteAncestors','off');
                    set_param(allSys{ii},'HiliteAncestors','fade');
                end
                highLightColor='lightBlue';
                if this.cloneDetectionStatus&&~isempty(this.blockPathCategoryMap)
                    if isKey(this.blockPathCategoryMap,this.blockFullPath)
                        categoryKey=this.blockPathCategoryMap(char(this.blockFullPath)).CloneGroupKey;
                        if contains(categoryKey,'Exact')
                            highLightColor=this.colorCodes.exactColor;
                        elseif contains(categoryKey,'Similar')
                            highLightColor=this.colorCodes.similarColor;
                        elseif contains(categoryKey,'Exclusion')
                            highLightColor=this.colorCodes.exclusionColor;
                        end
                    end
                end
                set_param(0,'HiliteAncestorsData',...
                struct('HiliteType','user2',...
                'ForegroundColor','black',...
                'BackgroundColor',highLightColor));
                hilite_system(this.blockFullPath,'user2');

            end
        end


        function isHier=isHierarchical(~)
            isHier=true;
        end
        function children=getHierarchicalChildren(this)
            children=this.children;
        end


        function isValid=isValidProperty(this,propName)
            switch propName
            case this.modelHierarchySSColumn1
                isValid=true;
            case this.modelHierarchySSColumn2
                isValid=true;
            otherwise
                isValid=false;
            end
        end



        function getPropertyStyle(this,aPropName,propertyStyle)
            aStyle=propertyStyle;
            propValue=this.getPropValue(aPropName);
            aStyle.Tooltip=propValue;
            aStyle.BackgroundColor=[1,1,1];



            if this.cloneDetectionStatus&&~isempty(this.blockPathCategoryMap)
                if isKey(this.blockPathCategoryMap,this.blockFullPath)
                    categoryKey=this.blockPathCategoryMap(char(this.blockFullPath)).CloneGroupKey;
                    if contains(categoryKey,'Exact')
                        aStyle.BackgroundColor=CloneDetectionUI.internal.util.getExactColorCodeNumerical;
                        aStyle.ForeGroundColor=[0,0,0];
                    elseif contains(categoryKey,'Similar')
                        aStyle.BackgroundColor=CloneDetectionUI.internal.util.getSimilarLightColorCodeNumerical;
                        aStyle.ForeGroundColor=[0,0,0];
                    elseif contains(categoryKey,'Exclusion')
                        aStyle.BackgroundColor=CloneDetectionUI.internal.util.getExclusionColorCodeNumerical;
                        aStyle.ForeGroundColor=[1,1,1];
                    end

                end
            end
        end


        function[bIsReadOnly]=isReadonlyProperty(~,~)
            bIsReadOnly=true;
        end

    end
end


