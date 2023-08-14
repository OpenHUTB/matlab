



classdef MatlabCodeAnalyzerConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Flag MATLAB code that have code analyzer messages';
        end


        function obj=MatlabCodeAnalyzerConstraint()
            obj.setEnum('MatlabCodeAnalyzer');
            obj.setFatal(false);
            obj.setCompileNeeded(0);
        end


        function out=check(aObj)

            out=[];

            assert(isa(aObj.getOwner(),'slci.simulink.Model'));
            systemName=aObj.getOwner().getName();
            [result,~,~]=...
            slci.internal.runCodeAnalyzerCheck(systemName);
            if~result
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'MatlabCodeAnalyzer');
            end

        end

    end

end
