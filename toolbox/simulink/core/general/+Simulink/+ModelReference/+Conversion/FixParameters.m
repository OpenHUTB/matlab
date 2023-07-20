




classdef FixParameters<Simulink.ModelReference.Conversion.AutoFix
    properties(Access=private)
System
SystemName
        ParameterName='';
        OldValue='';
        NewValue='';
ConversionData
ParameterMap
    end

    methods(Access=public)
        function this=FixParameters(subsys,paramName,newValue,params)
            this.System=subsys;
            this.ParameterName=paramName;
            this.NewValue=newValue;
            this.ConversionData=params;
            this.ParameterMap=this.ConversionData.ParameterMap;
        end

        function fix(this)
            this.update;
            this.OldValue=get_param(this.System,this.ParameterName);
            if~isequal(this.OldValue,this.NewValue)
                if slfeature('RightClickBuild')~=0&&this.ConversionData.ConversionParameters.RightClickBuild
                    try
                        linkstat=get_param(this.System,'LinkStatus');
                        if isequal(linkstat,'resolved')
                            set_param(this.System,'LinkStatus','inactive');
                        end
                    catch
                    end
                end
                set_param(this.System,this.ParameterName,this.NewValue);
            end
        end

        function results=getActionDescription(this)
            results={};
            if~isequal(this.OldValue,this.NewValue)
                subsysObj=Simulink.SubsystemType(this.System);
                paramName=this.beautifyParameterName(this.ParameterMap.getParamName(this.ParameterName));
                oldValue=this.ParameterMap.getParamValue(this.ParameterName,this.OldValue);
                newValue=this.ParameterMap.getParamValue(this.ParameterName,this.NewValue);
                if subsysObj.isSubsystem
                    results{end+1}=message('Simulink:modelReferenceAdvisor:ChangeSubsystemParameter',...
                    paramName,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(...
                    this.SystemName,this.System),oldValue,newValue);
                else
                    results{end+1}=message('Simulink:modelReferenceAdvisor:ChangeModelParameter',...
                    paramName,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(this.SystemName),...
                    oldValue,newValue);
                end
            end
        end
    end

    methods(Access=private)
        function update(this)
            if ishandle(this.System)
                this.SystemName=getfullname(this.System);
            else
                this.SystemName=this.System;
                this.System=get_param(this.SystemName,'Handle');
            end
        end
    end

    methods(Static,Access=private)
        function results=beautifyParameterName(paramName)
            if(paramName(end)==':')
                results=paramName(1:(end-1));
            else
                results=paramName;
            end
        end
    end
end
