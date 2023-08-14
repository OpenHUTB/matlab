classdef SlvrJacobianPattern















    properties
Jpattern
numColGroup
colGroup
stateNames
blockHandles
    end

    properties(SetAccess=private,Hidden=true)
JpatternABCD
    end

    methods
        function JpObj=SlvrJacobianPattern(JpStructIn)
            if(isfield(JpStructIn,'Jpattern'))
                JpObj.Jpattern=JpStructIn.Jpattern.A;
                JpObj.JpatternABCD=JpStructIn.Jpattern;
            end

            if(isfield(JpStructIn,'numColGroup'))
                JpObj.numColGroup=JpStructIn.numColGroup;
            end

            if(isfield(JpStructIn,'colGroup'))
                JpObj.colGroup=JpStructIn.colGroup;
            end

            if(isfield(JpStructIn,'stateNames'))
                JpObj.stateNames=JpStructIn.stateNames;
            end

            if(isfield(JpStructIn,'blockHandles'))
                JpObj.blockHandles=JpStructIn.blockHandles;
            end
        end

        function show(JpObj)

            nz=length(find(JpObj.Jpattern));
            nx=length(JpObj.Jpattern);
            axis([0,nx+0.5,0,nx+0.5]);
            spy(JpObj.Jpattern);
            title(['Sparsity pattern:   ','nz =',num2str(nz)]);
            xlabel('x');
            ylabel('$\dot{x}$','Interpreter','latex','Rotation',0);
            set(gca,'XTick',1:nx);
            set(gca,'YTick',1:nx);

        end
    end
end

