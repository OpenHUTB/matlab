classdef ElementDiagram<slreportgen.report.internal.DiagramBase















































































    properties(Dependent)








        Source;
    end

    properties(Constant,Access=protected)
        ImageTemplateName="ElementDiagramImage";
        NumberedCaptionTemplateName="ElementDiagramNumberCaption";
        HierNumberedCaptionTemplateName="ElementDiagramHierNumberCaption";
    end

    properties(Access=private)
        SourceValue;
        SourceHandle;
    end

    methods
        function this=ElementDiagram(varargin)
            this=this@slreportgen.report.internal.DiagramBase(varargin{:});


            if isempty(this.TemplateName)
                this.TemplateName="ElementDiagram";
            end
        end

        function value=get.Source(this)
            value=this.SourceValue;
        end

        function set.Source(this,value)
            if isempty(value)
                this.SourceValue=[];
                this.SourceHandle=[];
            else
                if ischar(value)
                    value=string(value);
                end
                this.SourceHandle=resolveSource(value);
                this.SourceValue=value;
            end
        end

        function impl=getImpl(this,rpt)
            if isempty(this.Source)
                error(message("slreportgen:report:error:noElementSpecified"));
            else
                impl=getImpl@slreportgen.report.Reporter(this,rpt);
            end
        end
    end

    methods(Access=protected)
        function snapObj=createSnapshotObject(this,varargin)
            snapObj=slreportgen.utils.internal.DiagramElementSnapshot(...
            this.SourceHandle,...
            "ShowBadges",false,...
            varargin{:});
        end

        function imageMap=createImageMap(~,~)
            imageMap=[];
        end
    end

    methods(Hidden,Access=protected)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)






            path=slreportgen.report.ElementDiagram.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.ElementDiagram");
        end
    end

end

function sourceH=resolveSource(value)
    try
        sourceH=slreportgen.utils.getSlSfHandle(value);
    catch
        error(message("slreportgen:report:error:invalidElementDiagramSource"))
    end

    valid=true;
    if isValidSlObject(slroot,sourceH)
        valueType=get_param(sourceH,"Type");
        if strcmp(valueType,"block_diagram")||strcmp(valueType,"port")
            valid=false;
        end
    elseif isa(sourceH,"Stateflow.Object")
        if isa(sourceH,"Stateflow.Chart")
            valid=false;
        end
    else
        valid=false;
    end
    if~valid
        error(message("slreportgen:report:error:invalidElementDiagramSource"))
    end
end