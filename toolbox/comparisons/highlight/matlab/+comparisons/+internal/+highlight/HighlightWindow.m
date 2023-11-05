classdef HighlightWindow<handle&matlab.mixin.Heterogeneous&comparisons.internal.highlight.Positionable

    methods(Abstract)

        canDisplay(obj,location)

        applyAttentionStyle(obj,location)

        clearAttentionStyle(obj)

        zoomToShow(obj,location)

        show(obj)

        hide(obj)

        isVisible(obj)
    end

end
