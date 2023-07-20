



classdef Assessment<Simulink.SimulationData.BlockData
    properties(Hidden)
        SSIdNumber=[];
        AssessmentId;
    end

    properties
        Result=slTestResult.Untested;
    end

    methods(Hidden)
        function str=getDisplayStr(this)
            str=sprintf('%s ''%s''',this.Result,this.Name);
        end
    end

    methods
        function disp(this)



            if length(this)~=1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end


            mc=metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n',mc.Name,mc.Name);
            else
                fprintf('  %s\n',mc.Name);
            end


            if~isempty(mc.ContainingPackage)
                fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);
            else
                fprintf('\n')
            end


            fprintf('  Properties:\n');
            ps.Name=this.Name;
            ps.BlockPath=this.BlockPath;
            ps.Values=this.Values;
            ps.Result=this.Result;
            disp(ps);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end
        end
    end
end
