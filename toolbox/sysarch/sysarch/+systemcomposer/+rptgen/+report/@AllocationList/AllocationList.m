classdef AllocationList<slreportgen.report.Reporter
























    properties

Source










AllocatedFrom










AllocatedTo





        IncludeAllocatedFrom=true





        IncludeAllocatedTo=true
    end

    methods(Access={?mlreportgen.report.ReportForm,?systemcomposer.rptgen.report.AllocationList})
        function arr=getAllocatedFrom(f,~)
            import mlreportgen.report.*
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            arr=[];
            if(f.IncludeAllocatedFrom)
                allocatedFrom=f.Source.AllocatedFrom;
                list=clone(f.AllocatedFrom);
                uniqueComponentsList=[];
                for comp=allocatedFrom
                    uniqueComponentsList=[uniqueComponentsList,comp];
                end
                uniqueComponentsList=unique(uniqueComponentsList);

                if~isempty(uniqueComponentsList)
                    for elem=uniqueComponentsList

                        append(list,elem);
                    end
                end
                if~isempty(list.Children)
                    emptySpace=mlreportgen.dom.Paragraph(" ");
                    title=mlreportgen.dom.Paragraph("Allocated From");

                    title.Style={Bold};
                    arr={emptySpace,title,list};
                end
            end
        end

        function arr=getAllocatedTo(f,rpt)
            import mlreportgen.report.*
            import slreportgen.report.*
            import slreportgen.finder.*
            import mlreportgen.dom.*
            import mlreportgen.utils.*
            arr=[];
            if(f.IncludeAllocatedTo)
                allocatedTo=f.Source.AllocatedTo;
                list=clone(f.AllocatedTo);
                uniqueComponentsList=[];
                for comp=allocatedTo
                    uniqueComponentsList=[uniqueComponentsList,comp];%#ok<*AGROW>
                end
                uniqueComponentsList=unique(uniqueComponentsList);

                if~isempty(uniqueComponentsList)
                    for elem=uniqueComponentsList
                        context=getContext(rpt,elem);
                        if~isempty(context)
                            linkID=systemcomposer.rptgen.utils.getObjectID(f.Source.Object,"Name",elem);
                            append(list,InternalLink(linkID,elem));
                        else
                            append(list,elem);
                        end
                    end
                end
                if~isempty(list.Children)
                    emptySpace=mlreportgen.dom.Paragraph(" ");
                    title=mlreportgen.dom.Paragraph("Allocated To");
                    title.Style={Bold};
                    arr={emptySpace,title,list};
                end
            end
        end
    end

    methods
        function this=AllocationList(varargin)
            if nargin==1
                varargin=["Source",varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});
            this.AllocatedFrom=mlreportgen.dom.OrderedList;
            this.AllocatedFrom.StyleName="Allocated From List";
            this.AllocatedTo=mlreportgen.dom.OrderedList;
            this.AllocatedTo.StyleName="Allocated To List";
            this.TemplateName="AllocationList";
        end
    end

    methods(Hidden)
        function templatePath=getDefaultTemplatePath(~,rpt)
            path=systemcomposer.rptgen.report.AllocationList.getClassFolder();
            templatePath=...
            mlreportgen.report.ReportForm.getFormTemplatePath(...
            path,rpt.Type);
        end
    end


    methods(Access=protected,Hidden)
        result=openImpl(rpt,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()
            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)
            path=systemcomposer.rptgen.report.AllocationList.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)
            classfile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"systemcomposer.rptgen.report.AllocationList");
        end
    end
end