classdef SectionConfig<handle




    properties(Access=public)
        SectionTitle(1,:)char=''
        IsSubsection(1,1)logical=false
        SubsectionFactories cell={}
        IncludeSubsectionTitleInSection(1,1)logical=false
        CreateImage{mustBeFunctionHandleOrEmpty}=[]
        NodeDelimiter(1,:)char='/'
    end

    properties(GetAccess={?comparisons.internal.report.tree.ComparisonReport,?comparisons.internal.report.tree.sections.TreeSection},...
        SetAccess={?comparisons.internal.report.tree.sections.TreeEntry,?comparisons.internal.report.tree.sections.TreeSection})
        ContainsDiffs(1,1)logical=false
    end

end

function mustBeFunctionHandleOrEmpty(createImage)
    valid=isempty(createImage)||isa(createImage,'function_handle');
    if~valid
        error("SectionConfig.CreateImage must be either empty or a function handle")
    end
end