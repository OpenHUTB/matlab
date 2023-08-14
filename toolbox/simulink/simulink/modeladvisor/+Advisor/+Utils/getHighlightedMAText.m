function msg=getHighlightedMAText(text,index)














    t1=ModelAdvisor.Text(text(1:index(1)-1));
    t1.RetainReturn=true;
    t1.RetainSpaceReturn=true;
    t1.ContentsContainHTML=0;

    t2=ModelAdvisor.Text(text(index(1):index(2)),{'bold'});
    t2.RetainReturn=true;
    t2.RetainSpaceReturn=true;
    t2.ContentsContainHTML=0;


    t3=ModelAdvisor.Text(text(index(2)+1:end));
    t3.RetainReturn=true;
    t3.RetainSpaceReturn=true;
    t3.ContentsContainHTML=0;


    msg=ModelAdvisor.Paragraph;
    msg.addItem(t1);
    msg.addItem(t2);
    msg.addItem(t3);

end