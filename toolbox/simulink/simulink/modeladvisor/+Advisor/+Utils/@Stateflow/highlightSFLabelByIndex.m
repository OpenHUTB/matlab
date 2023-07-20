function msg=highlightSFLabelByIndex(line,ind)




    before=1;
    after=length(line);
    newlines=regexp(line,'\n');
    if(~isempty(newlines))

        for k=1:length(newlines)
            if(newlines(k)<ind(1))


                before=newlines(k)+1;
            elseif(newlines(k)>=ind(2))
                after=newlines(k)-1;
                break;
            end
        end
    end
    tmp1=ModelAdvisor.Text(line(before:ind(1)-1));
    tmp2=ModelAdvisor.Text(line(ind(2)+1:after));
    tmp3=ModelAdvisor.Text(line(ind(1):ind(2)),{'bold'});
    msg=ModelAdvisor.Paragraph;
    tmp1.ContentsContainHTML=0;
    tmp2.ContentsContainHTML=0;
    tmp3.ContentsContainHTML=0;
    msg.addItem(tmp1);
    msg.addItem(tmp3);
    msg.addItem(tmp2);
end