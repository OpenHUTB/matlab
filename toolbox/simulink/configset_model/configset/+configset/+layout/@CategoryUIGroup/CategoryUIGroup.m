

classdef CategoryUIGroup<handle

    properties
Name
Type
Key
KeyFunction
Tag
CSHPath
TabTag
EnableTriggerType
Components
Children




        Advanced=false

    end

    properties(Access={?configset.layout.MetaConfigLayout,?configset.dialog.ConfigSetView})
IndexInParentGroup
ChildNeedsLabel
Feature

    end


    properties(Transient,Access={?configset.layout.MetaConfigLayout,?configset.dialog.ConfigSetView})
DialogSchemaFunction

ColumnHasLabel
        ChildHasCustomCSHPath={}
        ChildHasCustomCSHTag={}

ShowNames
ShowBorder
RowSizes
ColumnWidth
ActualColumnInfo
    end

    properties(Transient,Hidden)
NameEnglish
    end

    methods
        function obj=CategoryUIGroup(layout,domNode,tagPrefix,tabGroupTag,parentFeature)
            obj.Feature=parentFeature;
            obj.createFromXml(layout,domNode,tagPrefix,tabGroupTag);
        end

        out=isFeatureActive(obj)
    end

    methods(Hidden)
        createFromXml(obj,layout,groupNode,tagPrefix,tabGroupTag);
    end

end
