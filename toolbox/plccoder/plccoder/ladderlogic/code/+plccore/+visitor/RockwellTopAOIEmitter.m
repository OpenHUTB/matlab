classdef RockwellTopAOIEmitter<plccore.visitor.RockwellEmitter



    properties(Access=protected)
TopAOIName
    end

    properties(Access=private)
analyzer
    end

    methods
        function obj=RockwellTopAOIEmitter(ctx,aoi_name)
            obj@plccore.visitor.RockwellEmitter(ctx);
            obj.Kind='RockwellTopAOIEmitter';
            obj.TopAOIName=aoi_name;
        end

        function ret=generateCode(obj)
            import plccore.util.*;
            obj.createAnalyzer;
            obj.analyzeContext;
            obj.setupEmitter;
            obj.generateUDT;
            obj.generateAOI;
            ret=struct;
            ret.aoi_name=obj.TopAOIName;
            ret.udt_list=obj.getNameList(obj.getUDTList);
            ret.aoi_list=obj.getNameList(obj.getAOIList);
            ret.doc=obj.emitter.getDoc;
        end
    end

    methods(Access=protected)
        function createAnalyzer(obj)
            import plccore.visitor.*;
            obj.analyzer=TopAOIAnalyzer(obj.ctx,obj.TopAOIName);
            obj.analyzer.doit;
        end

        function ret=getUDTList(obj)
            import plccore.type.*;
            ret={};
            type_list=obj.analyzer.sortedTypeList;
            for i=1:length(type_list)
                type=type_list{i};
                if TypeTool.isNamedType(type)
                    ret{end+1}=type;%#ok<AGROW>
                end
            end
        end

        function ret=getAOIList(obj)
            ret=obj.analyzer.sortedFBList;
        end

        function ret=getNameList(obj,ir_list)%#ok<INUSL>
            sz=length(ir_list);
            ret=cell(1,sz);
            for i=1:sz
                ret{i}=ir_list{i}.name;
            end
        end
    end
end



