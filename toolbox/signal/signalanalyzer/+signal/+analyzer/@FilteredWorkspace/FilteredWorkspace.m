classdef FilteredWorkspace<internal.matlab.legacyvariableeditor.MLWorkspace&internal.matlab.legacyvariableeditor.MLNamedVariableObserver&dynamicprops





    properties
        currentVariables={};
    end

    methods
        function this=FilteredWorkspace()
            this@internal.matlab.legacyvariableeditor.MLNamedVariableObserver('who','base');
            this.updateVariables(evalin('base','who'));
        end

        function s=who(this)
            s=this.currentVariables;
        end

        function val=getPropValue(~,propName)
            val=evalin('base',propName);
        end

        function clearOldProps(this)
            for i=1:length(this.currentVariables)
                propName=this.currentVariables{i};
                if isprop(this,propName)
                    p=findprop(this,propName);
                    delete(p);
                end
            end
            this.currentVariables={};
        end

        function variableChanged(this,variables,~,~)
            this.updateVariables(variables);
        end

        function updateVariables(this,variables)
            if~iscell(variables)
                return;
            end


            this.clearOldProps();


            for i=1:length(variables)
                propName=variables{i};
                value=evalin('base',propName);


                if this.isValidVariable(propName,value)
                    this.currentVariables{end+1}=propName;
                    if~isprop(this,propName)
                        p=this.addprop(propName);
                        p.Dependent=true;
                        p.GetMethod=@(this)(this.getPropValue(propName));
                    end
                end
            end
            this.notify('VariablesChanged');
        end

        function passes=isValidVariable(~,name,value)
            passes=(~strcmp(name,'ans')&&~istall(value)&&~isempty(value)&&~isa(value,'gpuArray'))&&...
            (...
            (...
            (isnumeric(value)||islogical(value))...
            &&ndims(value)<=2...
            &&~isscalar(value)...
            &&~issparse(value)...
            )||...
            (...
            istimetable(value)&&length(value.Properties.RowTimes)>1...
            )||...
            (...
            isa(value,'timeseries')&&isscalar(value)&&length(value.Time)>1...
            )||...
            (...
            isa(value,'labeledSignalSet')&&isSupportedInSignalAnalyzer(value)&&value.NumMembers>0...
            )...
            );
        end
    end
end
