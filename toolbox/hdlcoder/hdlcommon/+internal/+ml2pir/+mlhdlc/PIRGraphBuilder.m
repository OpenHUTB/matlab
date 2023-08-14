classdef PIRGraphBuilder<internal.ml2pir.PIRGraphBuilder




    methods(Access=protected)

        function traceCmtPrefix=createTraceCmtPrefix(~)
            traceCmtPrefix='';
        end

        function fullPath=getRootPath(this,~)




            parentNetwork=this.PirOptions.ParentNetwork;
            fullPath=parentNetwork.fullPath;
        end

    end
end

