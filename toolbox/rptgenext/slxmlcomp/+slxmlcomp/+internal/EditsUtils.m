classdef EditsUtils<handle



    methods(Access=private)

        function obj=EditsUtils()

        end

    end


    methods(Access=public,Static)

        function factory=getEditsFactory()
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.two.TwoSLXComparisonDriver
            factory=@editsFactory;
        end

    end

end

function edits=editsFactory(comparisonDriver)
    slxDriver=comparisonDriver.getComparison();

    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.two.matlab.SLModelEditsDriverFacade;
    jDriverFacade=SLModelEditsDriverFacade(slxDriver);

    edits=xmlcomp.internal.edits.Edits.create(jDriverFacade);
end

