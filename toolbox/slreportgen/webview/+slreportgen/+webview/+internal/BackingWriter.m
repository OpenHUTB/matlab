classdef BackingWriter<handle




















    properties

        Indent uint8=0
    end

    properties(SetAccess=private)

View
    end

    properties(Access=private)
JSONWriter
        IsOpened logical=false;
    end

    methods
        function this=BackingWriter(view)
            this.View=view;
        end

        function open(this,filename)



            assert(~this.IsOpened);
            resetSupportFiles(this.View);
            this.JSONWriter=slreportgen.webview.JSONWriter();
            writer=this.JSONWriter;
            writer.Indent=this.Indent;
            writer.open(filename);
            writer.beginArray();
            this.IsOpened=true;
        end

        function write(this,id,slpobj)




            assert(this.IsOpened);
            writer=this.JSONWriter;
            writer.beginObject();
            writer.name("sid");
            writer.value(id);
            this.View.export(writer,slpobj);
            writer.endObject();
        end

        function close(this)


            assert(this.IsOpened);
            writer=this.JSONWriter;
            writer.endArray();
            writer.close();
            this.IsOpened=false;
            this.JSONWriter=[];
        end

        function[files,paths]=supportFiles(this)
            [files,paths]=this.View.supportFiles();
        end
    end
end
