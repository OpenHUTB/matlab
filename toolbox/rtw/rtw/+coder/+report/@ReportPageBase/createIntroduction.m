function createIntroduction(rpt)
    if~isempty(rpt.IntroductionContent)
        rpt.Introduction.setContent(rpt.IntroductionContent);
    end
end
