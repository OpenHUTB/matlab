classdef LHSVisitor<optim.internal.problemdef.ast.DefaultVisitor





    properties
PropertiesVisitor
    end

    methods

        function obj=LHSVisitor(ptiesVisitor)
            obj.PropertiesVisitor=ptiesVisitor;
        end



        function result=handleLHSVariable(interp,astVar)



            astVar.IsOptimExpr=true;
            if~isLHSVariable(astVar)



                createLHSVariable(astVar,interp.PropertiesVisitor);
            end
            result=[];
        end

    end
end
