classdef BlockSettings<simscape.internal.componentforwarding.ComponentSettings










    properties(Access=private)
ValueData
VariableSuffixes
rtconfigSuffix
    end

    properties(SetAccess=private)
Version
NewBlockPath
    end

    methods
        function obj=BlockSettings(params,values,version,pth)

            obj.ValueData=lGetValueDataFromInstanceData(params,values);
            obj.Version=version;
            obj.NewBlockPath=pth;

            nesl_variabletargetsuffixes=nesl_private('nesl_variabletargetsuffixes');
            obj.VariableSuffixes=nesl_variabletargetsuffixes();

            nesl_parametersuffixes=nesl_private('nesl_parametersuffixes');
            [~,~,obj.rtconfigSuffix]=nesl_parametersuffixes();

        end
        function value=getValue(obj,id)
            valueID=[id,obj.VariableSuffixes.varSuffix];
            if isfield(obj.ValueData,valueID)
                value=obj.ValueData.(valueID);
            else
                value='';
            end
        end
        function obj=setValue(obj,id,value)
            valueID=[id,obj.VariableSuffixes.varSuffix];
            obj.ValueData.(valueID)=value;
        end
        function unit=getUnit(obj,id)
            unitID=[id,obj.VariableSuffixes.unitSuffix];
            if isfield(obj.ValueData,unitID)
                unit=obj.ValueData.(unitID);
            else
                unit='';
            end
        end
        function obj=setUnit(obj,id,unit)
            unitID=[id,obj.VariableSuffixes.unitSuffix];
            obj.ValueData.(unitID)=unit;
        end
        function priority=getPriority(obj,id)
            priorityD=[id,obj.VariableSuffixes.prioritySuffix];
            if isfield(obj.ValueData,priorityD)
                priority=obj.ValueData.(priorityD);
            else
                priority='';
            end
        end
        function obj=setPriority(obj,id,priority)
            priorityD=[id,obj.VariableSuffixes.prioritySuffix];
            obj.ValueData.(priorityD)=priority;
        end
        function specify=getSpecify(obj,id)
            specifyID=[id,obj.VariableSuffixes.specifySuffix];
            if isfield(obj.ValueData,specifyID)
                specify=obj.ValueData.(specifyID);
            else
                specify='';
            end
        end
        function obj=setSpecify(obj,id,specify)
            specifyID=[id,obj.VariableSuffixes.specifySuffix];
            obj.ValueData.(specifyID)=specify;
        end
        function rtconfig=getRTConfig(obj,id)
            rtconfigID=[id,obj.rtconfigSuffix];
            if isfield(obj.ValueData,rtconfigID)
                rtconfig=obj.ValueData.(rtconfigID);
            else
                rtconfig='';
            end
        end
        function obj=setRTConfig(obj,id,rtconfig)
            rtconfigID=[id,obj.rtconfigSuffix];
            obj.ValueData.(rtconfigID)=rtconfig;
        end
        function class=getClass(obj)
            if isfield(obj.ValueData,'SourceFile')
                class=obj.ValueData.('SourceFile');
            elseif isfield(obj.ValueData,'ComponentPath')
                class=obj.ValueData.('ComponentPath');
            else
                pm_error('physmod:ne_sli:blockforwarding:ComponentPathNotFound');
            end
        end
        function obj=setClass(obj,class)
            obj.ValueData.('SourceFile')=class;
        end
        function version=getVersion(obj)
            version=obj.Version;
        end
        function obj=setVersion(obj,version)
            obj.Version=version;
        end
        function pth=getNewBlockPath(obj)
            pth=obj.NewBlockPath;
        end
        function obj=setNewBlockPath(obj,pth)
            obj.NewBlockPath=pth;
        end
        function obj=applyCustomTransform(obj,customTransform)
            if~isempty(customTransform)
                obj=feval(customTransform,obj);
            end
        end
    end

end

function structuredData=lGetValueDataFromInstanceData(params,values)
    for idx=1:numel(params)
        structuredData.(params{idx})=values{idx};
    end
end