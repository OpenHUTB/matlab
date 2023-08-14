









classdef DerivedSignal<Simulink.SimulationData.BlockData


    properties(Access='public')
        PortIndex=1;
        Expression='';
        SwitchPoleID='';
        Selected=0;
    end


    methods
        function this=set.Expression(this,val)
            this.Expression=val;
        end

        function out=get.Expression(this)
            out=this.Expression;
        end



        function this=set.PortIndex(this,val)

            validateattributes(val,{'numeric'},...
            {'real','integer','scalar','positive','nonsparse'});
            this.PortIndex=double(val);
        end


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


            fprintf('  Package: %s\n\n',mc.ContainingPackage.Name);


            fprintf('  Properties:\n');
            ps.Name=this.Name;
            ps.Expression=this.Expression;
            ps.SwitchPoleID=this.SwitchPoleID;





            disp(ps);


            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ',mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n',mc.Name);
            end

        end

        function sobj=saveobj(obj)
            sobj=obj;
        end



    end
end
