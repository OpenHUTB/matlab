function unhighlightBlock(blkHandle)




    styler=diagram.style.getStyler('slDebugBlockStyler');
    assert(~isempty(styler));
    if~isempty(styler)
        styler.removeClass(blkHandle,'slDebugGreenGlow');
    end
end


