classdef Diagram<slreportgen.report.internal.DiagramBase


































































































    properties(Dependent)














        Source;
    end

    properties





























        SnapshotArea{mustBeEmptyOrValidViewRect}=[];










































































        HyperLinkDiagram{mustBeLogical}=true;















        MaskedSystemLinkPolicy{mustBeMember(MaskedSystemLinkPolicy,["default","system","block"])}="default";
    end

    properties(Hidden)
        ShowImageMapBox=false;
    end

    properties(Constant,Access=protected)
        ImageTemplateName="DiagramImage";
        NumberedCaptionTemplateName="DiagramNumberedCaption";
        HierNumberedCaptionTemplateName="DiagramHierNumberedCaption";
    end

    properties(Access=private)



        HID=[];


        SourceValue;


        SourceHandle;


SnapshotObj
    end

    methods
        function this=Diagram(varargin)
            this=this@slreportgen.report.internal.DiagramBase(varargin{:});


            if isempty(this.TemplateName)
                this.TemplateName="Diagram";
            end
        end

        function value=get.Source(this)
            value=this.SourceValue;
        end

        function set.Source(this,value)
            this.SourceValue=[];
            this.SourceHandle=[];
            this.HID=[];

            if ischar(value)
                value=string(value);
            end

            if slreportgen.utils.hasDiagram(value)
                this.SourceValue=value;
                this.SourceHandle=slreportgen.utils.getSlSfHandle(value);
                this.HID=slreportgen.utils.HierarchyService.getDiagramHID(value);
            else
                error(message("slreportgen:report:error:invalidDiagramSource"));
            end
        end

        function impl=getImpl(this,rpt)
            if isempty(this.SourceHandle)
                error(message("slreportgen:report:error:noDiagramSpecified"));
            end



            diagFullPath=slreportgen.utils.getDiagramPath(this.HID);
            parentPath=slreportgen.utils.pathParts(diagFullPath);



            setContext(rpt,char(diagFullPath),this);


            if isempty(this.LinkTarget)&&~isempty(this.SourceHandle)
                makeLinkTarget=false;







                if(parentPath~="")
                    parentDiagram=getContext(rpt,char(parentPath));




                    hs=slreportgen.utils.HierarchyService;
                    ehid=hs.getElementHID(this.HID);
                    block=slreportgen.utils.getSlSfHandle(ehid);

                    if slreportgen.utils.isMaskedSystem(block)&&~isempty(parentDiagram)
                        if strcmp(parentDiagram.MaskedSystemLinkPolicy,"default")
                            makeLinkTarget=isValidTarget(this);
                        elseif strcmp(parentDiagram.MaskedSystemLinkPolicy,"system")
                            makeLinkTarget=true;
                        end
                    else



                        makeLinkTarget=isValidTarget(this);
                    end
                else


                    makeLinkTarget=isValidTarget(this);
                    block=this.SourceHandle;
                end

                if makeLinkTarget&&~isempty(block)
                    this.LinkTarget=slreportgen.utils.getObjectID(block);
                end
            end

            impl=getImpl@slreportgen.report.Reporter(this,rpt);
        end
    end

    methods(Access=protected)
        function snapObj=createSnapshotObject(this,varargin)
            snapObj=slreportgen.utils.internal.DiagramSnapshot(...
            this.SourceHandle,...
            "ShowBadges",true,...
            varargin{:});

            if~isempty(this.SnapshotArea)
                snapObj.View="custom";
                snapObj.ViewRect=this.SnapshotArea;
            end

            this.SnapshotObj=snapObj;
        end



        function isTarget=isValidTarget(this)
            isTarget=false;
            srcH=this.SourceHandle;
            objType=slreportgen.utils.getObjectType(srcH);
            if strcmp(objType,'System')||...
                strcmp(objType,'Model')||...
                strcmp(objType,'Chart')||...
                strcmp(objType,'SLFunction')||...
                (strcmp(objType,'Function')&&srcH.IsSubchart)||...
                (strcmp(objType,'State')&&srcH.IsSubchart)||...
                (strcmp(objType,'Box')&&srcH.IsSubchart)
                isTarget=true;
            end
        end

        function imageMap=createImageMap(this,rpt)
            if~this.HyperLinkDiagram
                imageMap=[];
            else
                imageMap=mlreportgen.dom.ImageMap;
                if this.ShowImageMapBox
                    imageMap.Style={mlreportgen.dom.Border('solid','red','2px')};
                end

                finder=slreportgen.finder.DiagramElementFinder(...
                "Container",this.SourceHandle,...
                "Types","atomic_subchart block box emfunction function junction slfunction state transition truthtable");



                finder.IncludeVariants="All";
                finder.IncludeCommented=true;

                snapObj=this.SnapshotObj;
                while hasNext(finder)
                    result=next(finder);
                    try
                        obj=result.Object;
                        pos=getSnapshotBounds(snapObj,obj);


                        if isempty(pos)||((pos(3)==0)||(pos(4)==0))
                            continue
                        end

                        imageArea=mlreportgen.dom.ImageArea();

                        if slreportgen.utils.isModelReferenceBlock(obj)
                            obj=get_param(obj,'ModelName');
                        end
                        target=slreportgen.utils.getObjectID(obj);



                        if ishtml(rpt)||ishtmlfile(rpt)
                            target=strcat("#",target);
                        end

                        imageArea.Target=target;
                        imageArea.Coords=[pos(1:2),pos(1:2)+pos(3:4)];
                        imageArea.Shape='rect';
                        append(imageMap,imageArea);
                    catch

                    end
                end
            end
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






            path=slreportgen.report.Diagram.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classfile=customizeReporter(toClasspath)









            classfile=mlreportgen.report.ReportForm.customizeClass(toClasspath,...
            "slreportgen.report.Diagram");
        end
    end
end

function mustBeLogical(varargin)
    mlreportgen.report.validators.mustBeLogical(varargin{:});
end

function mustBeEmptyOrValidViewRect(value)
    if~(isempty(value)...
        ||(isnumeric(value)&&numel(value)==4&&value(3)>0&&value(4)>0))
        error(message("slreportgen:report:error:mustBeEmptyOrValidViewArea"));
    end
end
