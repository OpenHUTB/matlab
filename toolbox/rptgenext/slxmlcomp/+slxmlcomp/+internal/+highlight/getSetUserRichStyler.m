function previousValue=getSetUserRichStyler(varargin)



    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.gui.highlight.SLXHighlightManagerFactory;
    import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.gui.highlight.HighlightType;

    previousValue=HighlightType.RICH.equals(...
    SLXHighlightManagerFactory.HIGHLIGHT_TYPE.get()...
    );

    if(nargin>=1)
        assert(islogical(varargin{1}),'Styler feature flag value must be a logical value');
        featureFlagValue=HighlightType.CLASSIC;
        if(varargin{1})
            featureFlagValue=HighlightType.RICH;
        end

        SLXHighlightManagerFactory.HIGHLIGHT_TYPE.getAndSet(featureFlagValue);
    end

end
