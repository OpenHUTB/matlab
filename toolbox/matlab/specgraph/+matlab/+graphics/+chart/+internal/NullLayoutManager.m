classdef NullLayoutManager<handle


















    properties
        Axes{mustBe_matlab_graphics_axis_AbstractAxes}
    end

    methods
        function lm=NullLayoutManager(peerAx)
            if isprop(peerAx,'LayoutManager')

                assert(isa(peerAx.LayoutManager,...
                'matlab.graphics.chart.internal.NullLayoutManager'));
                lm=peerAx.LayoutManager;
            else

                hP=addprop(peerAx,'LayoutManager');
                hP.Hidden=true;
                hP.Transient=true;
                peerAx.LayoutManager=lm;
                hP.SetAccess='private';
                lm.Axes=peerAx;
            end
        end

        function addToTree(varargin)


        end

        function enableAxesDirtyListeners(~,~)
        end
    end
end

function mustBe_matlab_graphics_axis_AbstractAxes(input)
    if~isa(input,'matlab.graphics.axis.AbstractAxes')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.graphics.axis.AbstractAxes').getString));
    end
end
