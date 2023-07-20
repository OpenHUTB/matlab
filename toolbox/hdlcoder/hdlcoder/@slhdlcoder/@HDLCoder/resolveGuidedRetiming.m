function[guidedRetiming,isRegenMode,guidanceFile]=resolveGuidedRetiming(this,gp)



    guidedRetiming=this.getParameter('guidedRetiming');
    guidanceFile=this.getParameter('optimizationData');
    isRegenMode=~isempty(guidanceFile);
    guidedRetiming=guidedRetiming||isRegenMode;
    gp.setGuidedRetiming(guidedRetiming);
end