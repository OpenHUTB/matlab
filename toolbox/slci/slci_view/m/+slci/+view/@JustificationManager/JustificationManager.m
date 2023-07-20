



classdef JustificationManager

    properties

fMfModel

fJustification
    end

    methods

        function obj=JustificationManager(model,fs)
            assert(isa(model,'mf.zero.Model'),"first argument of JustificationManager must be of type 'mf.zero.Model'");
            assert(isa(fs,'advisor.filter.SlciFilterSpecification'),"second argument of JustificationManager must be of type 'advisor.filter.SlciFilterSpecification'");
            obj.fMfModel=model;
            obj.fJustification=fs;
        end

    end

    methods

        function out=getSID(obj)
            out=obj.fJustification.id;
        end


        function out=getCodeLines(obj)
            out=obj.fJustification.codeLines;
        end

        function out=getMetadata(obj)
            out=obj.fJustification.metadata;
        end

        function out=getSummary(obj)
            out=obj.fJustification.metadata.summary;
        end

        function out=getDescription(obj)
            out=obj.fJustification.metadata.description;
        end

        function out=getUser(obj)
            out=obj.fJustification.metadata.user;
        end

        function out=getTimeStamp(obj)
            out=datetime(obj.fJustification.metadata.timeStamp,'InputFormat',...
            'dd-MMM-yyyy HH:mm:ss','Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss');
        end

        function out=getDeleted(obj)
            out=obj.fJustification.metadata.deleted;
        end

        function out=isDeleted(obj)

            out=obj.fJustification.metadata.deleted;
        end

        function out=getCommentThread(obj)
            out=obj.fJustification.commentThread;
        end


        function out=setCodeLines(obj,newData)
            out=obj.fJustification.codeLines;
            obj.fJustification.codeLines=newData;
        end


        function out=setUsingSuggestedTraceabillity(obj,newData)
            out=obj.fJustification.usingSuggestedTraceability;
            obj.fJustification.usingSuggestedTraceability=newData;
        end

        function out=setSummary(obj,newData)
            out=obj.fJustification.metadata.summary;
            obj.fJustification.metadata.summary=newData;
        end

        function out=setDescription(obj,newData)
            out=obj.fJustification.metadata.description;
            obj.fJustification.metadata.description=newData;
        end

        function out=setUser(obj,newData)
            out=obj.fJustification.metadata.user;
            obj.fJustification.metadata.user=newData;
        end

        function out=setTimeStamp(obj,newData)
            out=datetime(obj.fJustification.metadata.timeStamp,'InputFormat',...
            'dd-MMM-yyyy HH:mm:ss','Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss');
            obj.fJustification.metadata.timeStamp=datetime(newData,'InputFormat',...
            'dd-MMM-yyyy HH:mm:ss','Locale','en_US','Format','dd-MMM-yyyy HH:mm:ss');
        end

        function out=setDeleted(obj,newData)
            out=obj.fJustification.metadata.deleted;
            obj.fJustification.metadata.deleted=newData;
        end


        function addComment(obj,comment)
            obj.fJustification.commentThread.add(comment);
        end


        function clearComments(obj)
            obj.fJustification.commentThread.destroyAllContents();
        end


        setFieldsFromFilterJSON(obj,filterJSON);
        setFieldsFromFilterJSONDelete(obj,filterJSON);
        setFieldsFromFilterJSONEdit(obj,filterJSON);
        setFieldsFromFilterJSONHelper(obj,filterJSON);

    end
end
