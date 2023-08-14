



classdef(AllowedSubclasses=?configset.internal.data.WidgetStaticData)ParamStaticData<matlab.mixin.Copyable




    properties
        Name=''
        FullName=''
        DefaultValue=''
        Type=''
UI
Dependency
        DependencyOverride=false;
        Hidden=false;
        WidgetList;
        CallbackFunction='';
    end

    properties(Hidden)
v_AvailableValues
f_AvailableValues
f_Status

f_Tag
v_Tag
    end

    properties(Hidden)
ID
Order
Component

        Parent={}
        Children={}
        FullParent={}
        FullChildren={}

        CSH='';
        Custom=false;
        WidgetValuesFcn='';
        Inverted=false;

Feature


        ModelRef=[];
    end

    properties(Transient,Dependent)
DisplayedValues
Tag
    end

    properties(Dependent,Hidden)
UniqueName
    end

    properties(Transient,Hidden)


        Prompt=''
        Description=''
        ToolTip=''
    end

    properties(Transient,Hidden)
        PrototypeFeature='';


Constraint
ValueType
ConstraintType
Alias


        UDDProps=struct(...
        'nonSerialize',false,...
        'derived',false,...
        'prototype',false,...
        'grandfathered',false,...
        'private',false,...
        'noCopy',false,...
        'readOnly',false,...
        'externalReadOnly',false,...
        'writeToRTW',false,...
        'editableWhenLocked',false,...
        'editableWhenLockBypassed',false,...
        'okToShadow',false,...
        'mutable',false,...
        'forceSetCallback',false,...
        'evalParam',false,...
        'excludeFromCommon',false,...
        'noDirtyModel',false,...
        'updateParamEvent',false,...
        'redrawModel',false,...
        'noChecksum',false,...
        'freezeTimestamp',false,...
        'grandfatheredSpecialCase',false,...
        'migration',false...
        );
        Checksums={};
        HandWriteGet=false;
        HandWriteSet=false;
        ModelRefCompliance='';
Migration

    end

    properties(Hidden)
Location
    end


    methods
        function obj=ParamStaticData(param,varargin)

            if nargin==3
                obj.Name=varargin{2};
            end
            if nargin>=2
                cp=varargin{1};
            else
                cp.Name='';
                cp.tag='';
                cp.widgetId='';
                cp.key_prefix='';
                cp.key_suffix_name='';
            end

            if isstruct(param)
                obj.createFromTLC(param,cp);
            else
                obj.createFromXmlNode(param,cp);
            end
        end

        function out=get.DisplayedValues(obj)
            out=obj.getDisplayedValues();
        end

        function out=get.UniqueName(obj)
            if isempty(obj.Feature)
                out=obj.FullName;
            else
                if isnumeric(obj.Feature.Value)
                    out=[obj.FullName,':',obj.Feature.Name,':',num2str(obj.Feature.Value)];
                else
                    out=[obj.FullName,':',obj.Feature.Name,':true'];
                end
            end
        end

        function out=getParamName(obj)
            out=obj.Name;
        end

        function out=getParamFullName(obj)
            out=obj.FullName;
        end

        function out=get.Tag(obj)
            out=obj.v_Tag;
        end


    end

    methods(Access=public)
        out=checkStatus(obj,pValue,pStatus)
        out=AvailableValues(obj,varargin)
        out=getPrompt(obj,varargin)
        [out,availVals]=getDisplayedValues(obj,varargin)
        out=getToolTip(obj,varargin)
        out=getTag(obj,varargin)
        out=getDescription(obj)
        out=getAllowedValues(obj,varargin)
        out=getStatusDependsOn(obj)
        out=isCustom(obj)
        out=isFeatureActive(obj)
        opts=getOptions(obj,varargin)
        out=isInvertValue(obj)
        disp(obj)
    end

    methods(Access=protected)
        createFromXmlNode(obj,pNode,cp)
        checkXmlSyntax(obj,pNode,allowDeprecated)
    end

    methods(Access=private)
        createFromTLC(obj,param,cp)
        setup(obj)
    end

    methods(Access={?configset.internal.data.ConfigSetAdapter,...
        ?configset.internal.data.ParamStaticData,...
        ?configset.internal.data.WidgetStaticData})
        out=getStatus(obj,cs,varargin)
    end

    methods(Hidden)
        out=getInfo(obj,varargin)

        function out=HandWriteGetSet(obj)
            out=obj.HandWriteGet||obj.HandWriteSet;
        end
    end

    methods(Access=protected)
        function cp=copyElement(obj)
            cp=copyElement@matlab.mixin.Copyable(obj);
            if~isempty(obj.WidgetList)
                cp.WidgetList=cell(1,length(obj.WidgetList));
                for i=1:length(obj.WidgetList)
                    cp.WidgetList{i}=copy(obj.WidgetList{i});
                end
            end
        end
    end
end



