


classdef SLXMLComparisonBuilder<xmlcomp.internal.ComparisonBuilder

    properties(Access=private)
        FilterState slxmlcomp.internal.filter.FilterState
    end


    methods(Access=public)

        function obj=SLXMLComparisonBuilder()
            obj.FilterState=slxmlcomp.internal.filter.FilterState;
        end

        function obj=addFile(obj,filePath)

            [fullpath,~,extension]=obj.locateFile(filePath);


            if~ismember(extension,{'.mdl','.slx'})
                slxmlcomp.internal.error('xmlexport:ProcessOnlyMDL',filePath);
            end
            obj.addSource(fullpath);

        end

        function obj=setFilterState(obj,filterState)
            obj.FilterState=filterState;
        end

        function comparisonDriver=build(obj)
            import com.mathworks.toolbox.rptgenxmlcomp.parameters.CParameterInitialFilter;
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.parameters.CParameterLowMemoryWarning;
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.matlab.WarnInMATLABLowMemoryPrompt;

            if~isempty(obj.FilterState)
                obj.addParameter(...
                CParameterInitialFilter.getInstance(),...
                obj.getJFilterDefinition()...
                );
            end
            obj.addParameter(...
            CParameterLowMemoryWarning.getInstance(),...
            WarnInMATLABLowMemoryPrompt()...
            );

            comparisonDriver=build@xmlcomp.internal.ComparisonBuilder(obj);

        end

    end

    methods(Access=private)

        function filterDef=getJFilterDefinition(obj)
            import com.mathworks.comparisons.filter.definitions.*;
            userFilters=java.util.ArrayList();
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.filter.*
            if(obj.FilterState.CosmeticParameters)
                userFilters.add(NonFunctionalChangesFilterDefinition());
            end

            if(obj.FilterState.Lines)
                userFilters.add(LinesFilterDefinition());
            end

            if(obj.FilterState.BlockParameterDefaults)
                userFilters.add(BlockParameterDefaultsFilterDefinition());
            end

            for customFilter=obj.FilterState.CustomFilters'
                userFilters.add(customFilter{1});
            end

            import com.mathworks.comparisons.filter.tree.UIFilterStateFilterDefinitionBuilder;
            filterDef=UIFilterStateFilterDefinitionBuilder.buildFilterDefFromUserFilterList(...
            userFilters,...
            obj.getJShowState()...
            );
        end

        function jShow=getJShowState(obj)
            import com.mathworks.comparisons.filter.user.FilterMode;
            if(obj.FilterState.Show)
                jShow=FilterMode.SHOW;
            else
                jShow=FilterMode.HIDE;
            end
        end

        function[fullpath,name,extension]=locateFile(obj,file)
            try
                fullpath=comparisons.internal.resolvePath(file);
                [~,name,extension]=slfileparts(fullpath);
            catch exception
                if obj.isUnsavedModel(file)
                    slxmlcomp.internal.error('xmlexport:UnsavedModel',file)
                end
                exception.rethrow();
            end
        end

        function bool=isUnsavedModel(~,supplied_name)




            returned_name=which(supplied_name);
            bool=strcmp(returned_name,'new Simulink model')...
            &&~strcmp(returned_name,supplied_name);
        end

    end

end

