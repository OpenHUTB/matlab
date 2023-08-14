


classdef ModelManager

    properties

fMFModel

fManager
    end

    properties(Access=private)
fParser
    end

    methods

        function obj=ModelManager(fname)
            assert(isfile(fname),"Justification Json file does not exist");
            obj.fMFModel=mf.zero.Model;
            obj.fManager=advisor.filter.SlciFilterManager(obj.fMFModel);
            obj.fParser=mf.zero.io.JSONParser;
            obj.fManager=obj.fParser.parseFile(fname);
            obj.fMFModel=obj.fParser.Model;
        end

    end

    methods

        function out=getModel(obj)
            out=obj.fMFModel;
        end


        function out=getManager(obj)
            out=obj.fManager;
        end


        function out=setManager(obj,newManager)
            out=obj.fManager;
            obj.fManager=newManager;
        end


        function out=isFiltered(obj,sid)
            out=obj.fManager.isFiltered(sid);
        end


        function out=isDeleted(obj,sid)
            out=0;
            if obj.isFiltered(sid)
                out=obj.fManager.getFilterSpecification(advisor.filter.FilterType.Block,sid).metadata.deleted;
            end

        end


        out=getJustification(obj,sid);


        function out=getJustificationManager(obj,sid)
            fs=obj.getJustification(sid);
            out=slci.view.JustificationManager(obj.fMFModel,fs);
        end


        function out=deleteJustification(obj,sid)
            out=0;
            if obj.isFiltered(sid)
                out=obj.fManager.removeAnnotation(sid);
            end
        end

    end
end
