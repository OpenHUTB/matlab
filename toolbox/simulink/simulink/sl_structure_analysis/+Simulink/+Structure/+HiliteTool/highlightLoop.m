function styler=highlightLoop(loopInfo)












    if loopInfo.IsInLoop
        StyleManager=Simulink.Structure.HiliteTool.styleManager;
        StyleManager.applyCurrentTraceStyling(loopInfo.Elements,...
        loopInfo.ParentSystem);
        styler=StyleManager;
        warning(message('Simulink:HiliteTool:LoopDetectionClearHighlight'));
    end
end