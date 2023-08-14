function init(obj)
    obj.Doc=Advisor.Document;
    obj.Toc=Advisor.Element;
    obj.Toc.setTag('div');
    obj.TocItems=Advisor.List;
    obj.Introduction=Advisor.Element;
    obj.Introduction.setTag('div');
    obj.IntroductionContent='';
    obj.sectionNum=0;
    obj.TableID=0;
end
