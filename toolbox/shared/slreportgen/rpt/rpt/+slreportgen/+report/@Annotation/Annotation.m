classdef Annotation<slreportgen.report.Reporter
































































    properties





        Object{mustBeValidAnnotation(Object)}=[];
    end

    properties(Access=private)

        ObjectHandle;
    end

    methods
        function this=Annotation(varargin)
            if(nargin==1)
                varargin=[{"Object"},varargin];
            end
            this=this@slreportgen.report.Reporter(varargin{:});





            p=inputParser;




            p.KeepUnmatched=true;




            addParameter(p,"TemplateName","Annotation");
            addParameter(p,"Object",[]);


            parse(p,varargin{:});



            results=p.Results;
            this.TemplateName=results.TemplateName;
        end

        function impl=getImpl(this,rpt)

            if isempty(this.Object)
                error(message("slreportgen:report:error:noSourceObjectSpecified",class(this)));
            else

                this.ObjectHandle=slreportgen.utils.getSlSfHandle(this.Object);

                if isempty(this.LinkTarget)
                    obj=this.Object;
                    if or(isa(obj,"slreportgen.finder.DiagramElementResult"),isa(obj,"slreportgen.finder.AnnotationResult"))
                        obj=obj.Object;
                    end

                    parent=get_param(obj,'Parent');
                    hs=slreportgen.utils.HierarchyService;
                    dhid=hs.getDiagramHID(parent);
                    parentPath=hs.getPath(dhid);

                    if~isempty(parentPath)
                        parentDiagram=getContext(rpt,parentPath);
                        if~isempty(parentDiagram)&&(parentDiagram.HyperLinkDiagram)
                            this.LinkTarget=slreportgen.utils.getObjectID(obj);
                        end
                    end
                end


                impl=getImpl@slreportgen.report.Reporter(this,rpt);
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?slreporten.report.Annotation})
        function content=getContent(this,~)




            if strcmpi(get_param(this.ObjectHandle,"IsImage"),"on")
                content=[];
                return;
            end



            annotation=get_param(this.ObjectHandle,'Object');

            interpreter=mlreportgen.utils.toString(annotation.interpreter);
            switch lower(interpreter)
            case 'tex'


                content=mlreportgen.report.Equation(annotation.Text);
            case 'rich'
                html=string(annotation.Text);
                html=mlreportgen.utils.tidy(html,...
                'ConfigFile',fullfile(toolboxdir("shared"),'mlreportgen','utils','resources','tidy-xhtml-no-wrap.cfg'));
                system=annotation.Path;
                path=strsplit(system,'/');
                unpackedLocation=get_param(path{1},'UnpackedLocation');
                html=strrep(html,'[$unpackedFolder]',unpackedLocation);
                domHTML=mlreportgen.dom.HTML(html);



                content=mlreportgen.dom.Table(1);
                row=mlreportgen.dom.TableRow();
                entry=mlreportgen.dom.TableEntry();
                height=annotation.Position(4)-annotation.Position(2);
                width=annotation.Position(3)-annotation.Position(1);
                content.Style={mlreportgen.dom.Height(height+"px"),mlreportgen.dom.Width(width+"px")};
                append(entry,domHTML);
                append(row,entry);
                append(content,row);
            otherwise
                content=mlreportgen.dom.Paragraph(annotation.Text);
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(reporter,impl,varargin)
    end

    methods(Static)
        function path=getClassFolder()



            [path]=fileparts(mfilename('fullpath'));
        end

        function template=createTemplate(templatePath,type)








            path=slreportgen.report.Annotation.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.Annotation");
        end
    end
end

function mustBeValidAnnotation(value)

    if~isempty(value)
        objHandle=slreportgen.utils.getSlSfHandle(value);
        if~strcmpi(get_param(objHandle,"Type"),"Annotation")
            error(message("slreportgen:report:error:invalidSourceObject"));
        end
    end
end
