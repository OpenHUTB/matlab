classdef FilteredWorkspace<internal.matlab.legacyvariableeditor.MLWorkspace&internal.matlab.legacyvariableeditor.MLNamedVariableObserver&dynamicprops





    properties
        currentVariables={};
        filteredSources="";
        isIncludeFileData=true;
        isIncludeInMemoryData=true;
        isIncludeLSSInSamples=true;
        isIncludeDataWithTime=true;
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

        function passes=isValidVariable(this,name,value)
            passes=(~strcmp(name,'ans')&&~istall(value)&&~isempty(value)&&~isa(value,'gpuArray')&&~iscell(value))&&...
            (...
            (...
            this.isIncludeInMemoryData&&signal.labeler.FilteredWorkspace.checkNumericValue(value)...
            )||...
            (...
            this.isIncludeInMemoryData&&signal.labeler.FilteredWorkspace.checkCellOfVectors(value)...
            )||...
            (...
            this.isIncludeInMemoryData&&this.isIncludeDataWithTime...
            &&signal.labeler.FilteredWorkspace.checkCellOfTimetables(value)...
            )||...
            (...
            this.isIncludeInMemoryData&&this.isIncludeDataWithTime...
            &&signal.labeler.FilteredWorkspace.checkTimetable(value)...
            )||...
            (...
            isa(value,'labeledSignalSet')&&isSupportedInSignalLabeler(value)&&value.NumMembers>0...
            &&signal.labeler.FilteredWorkspace.checkForTimeInfo(value,this.isIncludeLSSInSamples,this.isIncludeDataWithTime,this.isIncludeFileData)...
            &&signal.labeler.FilteredWorkspace.checkForFilteredLssSource(value.getPrivateSourceData,this.isIncludeInMemoryData,this.isIncludeFileData,this.filteredSources))...
            );
        end
    end

    methods(Static)
        function flag=checkNumericValue(value)
            flag=isnumeric(value)&&ndims(value)<=2&&~isscalar(value)&&allfinite(value(:))&&~issparse(value);
        end

        function flag=checkCellOfVectors(value)


            flag=iscell(value)&&all(cellfun(@signal.labeler.FilteredWorkspace.checkNumericValueForCell,value));
        end

        function flag=checkNumericValueForCell(value)
            flag=isnumeric(value)&&isvector(value)&&~isscalar(value)&&allfinite(value(:))&&~issparse(value);
        end

        function flag=checkCellOfTimetables(value)


            flag=iscell(value)&&all(cellfun(@signal.labeler.FilteredWorkspace.checkTimetable,value));
        end

        function flag=checkTimetable(value)
            flag=istimetable(value)&&isduration(value.Properties.RowTimes)&&...
            all(varfun(@signal.labeler.FilteredWorkspace.checkNumericValue,value,'OutputFormat','uniform'));
        end

        function flag=checkForFilteredLssSource(value,isIncludeInMemoryData,isIncludeFileData,filteredSources)
            if isIncludeFileData&&isIncludeInMemoryData

                flag=true;
            elseif isIncludeFileData

                for idx=1:numel(filteredSources)
                    flag=isa(value,filteredSources{idx});
                    if~flag
                        return;
                    end
                end
            elseif isIncludeInMemoryData

                for idx=1:numel(filteredSources)
                    flag=~isa(value,filteredSources(idx));
                    if~flag
                        return;
                    end
                end
            end
        end

        function flag=checkForTimeInfo(lss,isIncludeLSSInSamples,isIncludeDataWithTime,isIncludeFileData)
            if isIncludeFileData||isIncludeLSSInSamples&&isIncludeDataWithTime


                flag=true;
            elseif isIncludeLSSInSamples
                flag=lss.TimeInformation=="none";
            elseif isIncludeDataWithTime
                flag=lss.TimeInformation~="none";
            end
        end

    end
end
