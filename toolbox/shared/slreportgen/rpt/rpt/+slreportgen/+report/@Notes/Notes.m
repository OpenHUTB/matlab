classdef Notes<slreportgen.report.Reporter






















































    properties(Dependent)


        Source;









        NoteType;
    end

    properties









        ReportOnInheritNoteType{mlreportgen.report.validators.mustBeLogical}=false;
    end

    properties(Access=private)
        HID=[];
        SourceValue=[];
        NotesPrinter;
        InternalLinkTarget;
    end

    methods
        function this=Notes(varargin)

            if(nargin==1)
                varObj=varargin{1};
                varargin={"Source",varObj};
            end

            this=this@slreportgen.report.Reporter(varargin{:});


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,"TemplateName","Notes");
            parse(p,varargin{:});


            results=p.Results;
            this.TemplateName=results.TemplateName;
        end

        function set.Source(this,value)
            hs=slreportgen.utils.HierarchyService;

            if ischar(value)
                value=string(value);
            end

            if isempty(value)
                this.HID=[];
                this.SourceValue=[];
            else
                try
                    hid=hs.getDiagramHID(value);
                catch

                    error(message("slreportgen:report:Notes:InvalidSource"));
                end

                this.HID=hid;
                this.SourceValue=value;
            end

            this.InternalLinkTarget=mlreportgen.utils.normalizeLinkID("notes-"+hs.getPath(hid));
        end

        function source=get.Source(this)
            source=this.SourceValue;
        end

        function noteType=get.NoteType(this)
            noteType=getNoteType(this,this.HID);
        end

        function impl=getImpl(this,rpt)
            if isempty(this.Source)

                error(message("slreportgen:report:Notes:SourceNotSpecified"));
            else
                initNotesPrinter(this,rpt);
                impl=getImpl@slreportgen.report.Reporter(this,rpt);
            end
        end

        function htmlContent=exportToHTML(this)




            if strcmp(this.NoteType,"Internal")
                np=getNotesPrinter(this);
                htmlContent=string(getNotesHTMLFromHID(np,this.HID));
            else
                error(message(...
                "slreportgen:report:Notes:ExportToHTMLNotAvailable",this.NoteType));
            end
        end

        function fullFilename=exportToHTMLFile(this,filename)





            htmlContent=exportToHTML(this);
            fullFilename=mlreportgen.utils.findFile(filename,...
            "FileMustExist",false);
            fid=fopen(fullFilename,"w","n","UTF-8");
            fprintf(fid,"%s",htmlContent);
            fclose(fid);
        end

        function url=getURL(this)




            if strcmp(this.NoteType,"External")
                np=getNotesPrinter(this);
                url=string(getNotesHTMLFromHID(np,this.HID));
            else
                error(message(...
                "slreportgen:report:Notes:URLNotAvailable",this.NoteType));
            end
        end

        function[srcH,hierPath]=getInheritedNoteSource(this)





            if(this.NoteType~="Inherit")
                error(message(...
                "slreportgen:report:Notes:InheritedSrcNotAvailable",this.NoteType));
            end

            srcH=[];
            hierPath=string.empty();

            pHID=this.HID;
            hs=slreportgen.utils.HierarchyService;
            while hs.isValid(pHID)
                if~strcmp(getNoteType(this,pHID),"Inherit")
                    srcH=slreportgen.utils.getSlSfHandle(pHID);
                    hierPath=hs.getPath(pHID);
                    return;
                end
                pHID=hs.getParentDiagramHID(pHID);
            end
        end
    end

    methods(Access={?mlreportgen.report.ReportForm,?slreportgen.report.Notes})
        function content=getContent(this,rpt)
            switch this.NoteType
            case "Internal"
                htmlstr=exportToHTML(this);


                head=extractBefore(htmlstr,"</head>");
                body=extractAfter(htmlstr,"</head>");

                head=replace(head,"white-space: pre-wrap;","");
                if strcmp(rpt.Type,"pdf")

                    head=regexprep(head,"font-family:[a-zA-Z0-9\.\s\(\)\-\,]*;+","");
                end
                htmlstr=strcat(head,"</head>",body);

                htmlstr=mlreportgen.utils.html2dom.prepHTMLString(htmlstr);
                content={...
                mlreportgen.dom.LinkTarget(this.InternalLinkTarget),...
                mlreportgen.dom.HTML(htmlstr)};

            case "External"
                url=getURL(this);
                content=mlreportgen.dom.ExternalLink(url,url);

            case "Inherit"
                if this.ReportOnInheritNoteType
                    [noteSource,noteSourcePath]=getInheritedNoteSource(this);
                    noteSourceReporter=slreportgen.report.Notes(noteSource);

                    if strcmpi(noteSourceReporter.NoteType,"External")

                        url=getURL(noteSourceReporter);
                        content=mlreportgen.dom.ExternalLink(url,url);

                    else

                        content=mlreportgen.dom.InternalLink(...
                        noteSourceReporter.InternalLinkTarget,...
                        noteSourcePath);
                    end
                else
                    content=[];
                end

            otherwise
                content=[];
            end
        end
    end

    methods(Access=protected,Hidden)

        result=openImpl(this,impl,varargin)
    end

    methods(Access=private)
        function initNotesPrinter(this,rpt)
            np=getContext(rpt,"NotesPrinter");
            if isempty(np)
                np=simulink.notes.internal.NotesPrinter();
                setContext(rpt,"NotesPrinter",np);
            end
            this.NotesPrinter=np;
        end

        function np=getNotesPrinter(this)
            np=this.NotesPrinter;
            if isempty(np)
                np=simulink.notes.internal.NotesPrinter();
            end
        end

        function noteType=getNoteType(this,src)
            np=getNotesPrinter(this);
            try
                type=getNotesType(np,src);
                switch type
                case 1
                    noteType="Internal";
                case 2
                    noteType="External";
                case 3
                    noteType="Inherit";
                case{4,5,-1}
                    noteType="None";
                case 6
                    noteType="Internal";
                end
            catch
                noteType="None";
            end
        end
    end

    methods(Static)
        function path=getClassFolder()


            [path]=fileparts(mfilename("fullpath"));
        end

        function template=createTemplate(templatePath,type)






            path=slreportgen.report.Notes.getClassFolder();
            template=mlreportgen.report.ReportForm.createFormTemplate(...
            templatePath,type,path);
        end

        function classFile=customizeReporter(toClasspath)










            classFile=mlreportgen.report.ReportForm.customizeClass(...
            toClasspath,"slreportgen.report.Notes");
        end
    end
end

