function styler=getSlDebugBlockStyler()





    styler=diagram.style.getStyler('slDebugBlockStyler');
    if isempty(styler)
        diagram.style.createStyler('slDebugBlockStyler');
        styler=diagram.style.getStyler('slDebugBlockStyler');
        glowStyle=diagram.style.Style;


        glowConfig=MG2.GlowEffect;
        glowConfig.Color=[0,.5,0,1];
        glowConfig.Spread=10;
        glowConfig.Gain=2;

        glowStyle.set('Glow',glowConfig);
        ruleName='slDebugGreenGlow';

        glowClass=diagram.style.MultiSelector({ruleName},{'Editor'});
        styler.addRule(glowStyle,glowClass);
    end
end


