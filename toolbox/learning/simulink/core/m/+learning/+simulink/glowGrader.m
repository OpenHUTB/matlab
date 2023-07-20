


classdef glowGrader

    properties(Constant)
        GLOW_REMOVE='Blank';
    end
    methods(Static)
        function glowConfig=glowForObj(issueType)
            glowConfig=MG2.GlowEffect;
            switch issueType
            case learning.simulink.glowEnum.Blank
                return
            case learning.simulink.glowEnum.Red
                glowConfig.Color=[1,0,0,1];
            case learning.simulink.glowEnum.Green
                glowConfig.Color=[0,.5,0,1];
            case learning.simulink.glowEnum.Yellow
                glowConfig.Color=[0.9,0.5,0.0,0.9];
            end

            glowConfig.Spread=10;
            glowConfig.Gain=2;

        end

        function styler=getOrCreateRule(GLOW_STYLER)

            styler=diagram.style.getStyler(GLOW_STYLER);
            if isempty(styler)
                diagram.style.createStyler(GLOW_STYLER);
                styler=diagram.style.getStyler(GLOW_STYLER);

                for i=-1:2
                    glowStyle=diagram.style.Style;

                    glowConfig=learning.simulink.glowGrader.glowForObj(i);
                    glowStyle.set('Glow',glowConfig);

                    ruleName=char(learning.simulink.glowEnum(i));

                    glowClass=diagram.style.MultiSelector({ruleName},{'Editor'});
                    styler.addRule(glowStyle,glowClass);
                end
            end
        end

        function setGlow(blockHandle,issueType,GLOW_STYLER)
            styler=learning.simulink.glowGrader.getOrCreateRule(GLOW_STYLER);
            styler.clearClasses(blockHandle);

            ruleName=char(learning.simulink.glowEnum(issueType));

            styler.applyClass(blockHandle,ruleName);
        end

        function clearAllGlows(GLOW_STYLER,modelName)
            styler=diagram.style.getStyler(GLOW_STYLER);
            if(~isempty(styler))
                diagramObj=diagram.resolver.resolve(modelName);
                styler.clearChildrenClasses('Red',diagramObj);
                styler.clearChildrenClasses('Yellow',diagramObj);
                styler.clearChildrenClasses('Green',diagramObj);
            end
        end
    end
end
