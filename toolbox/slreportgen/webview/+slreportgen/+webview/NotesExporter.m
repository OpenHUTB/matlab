classdef(Hidden)NotesExporter<handle












    properties(Access=private)
Engine
Printer
SourceMap
    end

    properties(Access=private,Constant)
        INTERNAL_TYPE=1;
        EXTERNAL_TYPE=2;
        INHERIT_TYPE=3;
        NONE_TYPES=[4,5,-1];
    end

    methods(Static)
        function tf=hasNotes(modelH)




            modelH=slreportgen.utils.getModelHandle(modelH);
            tf=~isempty(get_param(modelH,"Notes"));
        end
    end

    methods
        function this=NotesExporter(engine)
            this.Printer=simulink.notes.internal.NotesPrinter();
            this.Engine=engine;
            this.SourceMap=containers.Map(...
            "KeyType","uint64",...
            "ValueType","any");
        end

        function out=export(this,hierItem)







            type=this.Printer.getNotesType(hierItem.getDiagramHierarchyId());
            switch type
            case this.INTERNAL_TYPE
                out=this.exportInternalNotes(hierItem);

            case this.EXTERNAL_TYPE
                out=this.exportExternalNotes(hierItem);

            case this.INHERIT_TYPE
                out=this.exportInheritedNotes(hierItem);

            otherwise
                out=this.exportNoNotes(hierItem);
            end
        end
    end

    methods(Access=private)
        function out=exportInternalNotes(this,hierItem)
            fileName=sprintf("%s_%d_notes.html",...
            hierItem.getRoot().getName(),hierItem.ID);
            filePath=fullfile(this.Engine.BaseDir,fileName);
            pkgPath=strcat(this.Engine.BaseUrl,"/",fileName);

            fid=fopen(filePath,"w","n","UTF-8");
            hid=hierItem.getDiagramHierarchyId();
            content=this.Printer.getNotesHTMLFromHID(hid);

            content=strrep(content,'.rtcContent { padding: 30px; }','.rtcContent { padding: 0px; }');

            fprintf(fid,"%s",content);
            fclose(fid);

            this.Engine.addFile(filePath,pkgPath);
            notes=struct(...
            "type","internal",...
            "data",pkgPath);

            if hierItem.isChecked()


                this.SourceMap(hierItem.ID)=hierItem.ID;
                out=notes;
            else

                this.SourceMap(hierItem.ID)=notes;
                out=[];
            end
        end

        function out=exportExternalNotes(this,hierItem)
            hid=hierItem.getDiagramHierarchyId();
            notes=struct(...
            "type","external",...
            "data",string(this.Printer.getNotesHTMLFromHID(hid)));

            if hierItem.isChecked()


                this.SourceMap(hierItem.ID)=hierItem.ID;
                out=notes;
            else

                this.SourceMap(hierItem.ID)=notes;
                out=[];
            end
        end

        function out=exportInheritedNotes(this,hierItem)

            if hierItem.isRoot()

                out=[];
                this.SourceMap(hierItem.ID)=-1;
                return
            end

            parentItem=hierItem.getParent();
            if~this.SourceMap.isKey(parentItem.ID)

                this.export(parentItem);
            end

            this.SourceMap(hierItem.ID)=this.SourceMap(parentItem.ID);
            if~parentItem.isChecked()
                this.SourceMap(parentItem.ID)=hierItem.ID;
            end

            if hierItem.isChecked()
                if isstruct(this.SourceMap(hierItem.ID))
                    out=this.SourceMap(hierItem.ID);
                    this.SourceMap(hierItem.ID)=hierItem.ID;
                else
                    out=struct(...
                    "type","inherit",...
                    "data",this.SourceMap(hierItem.ID));
                end
            else
                out=[];
            end
        end

        function out=exportNoNotes(this,hierItem)
            out=[];
            this.SourceMap(hierItem.ID)=-1;
        end
    end
end
