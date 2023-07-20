function clearBlockEffects(modelName)

    learning.simulink.glowGrader.clearAllGlows('GlowGrader',modelName);

    learning.simulink.clearAllGraderBadges();
end

