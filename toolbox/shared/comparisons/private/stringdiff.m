function[t1,t2]=stringdiff(str1,str2)











    str1=i_tokenize(str1);
    str2=i_tokenize(str2);

    [a1,a2]=diffcode(str1,str2);
    nlines=numel(a1);
    out1=cell(nlines,1);
    out2=cell(nlines,1);


    for i=1:numel(a1)
        line1=a1(i);
        line2=a2(i);
        if line1~=0
            if line2~=0
                if strcmp(str1{line1},str2{line2})

                    out1{i}=i_unmodified(code2html(str1{line1}));
                    out2{i}=i_unmodified(code2html(str2{line2}));
                else

                    [h1,h2]=linediff(str1{line1},str2{line2});
                    out1{i}=i_modified(h1);
                    out2{i}=i_modified(h2);
                end
            else

                out1{i}=i_removed(code2html(str1{line1}));
                out2{i}=i_blank;
            end
        else

            assert(line2~=0);
            out1{i}=i_blank;
            out2{i}=i_added(code2html(str2{line2}));

        end
    end
    t1=sprintf('%s\n','<html>',out1{:},'</html>');
    t2=sprintf('%s\n','<html>',out2{:},'</html>');
end

function str=i_tokenize(str)
    if~isempty(str)
        str=textscan(str,'%s','delimiter',sprintf('\n'));
        str=str{1};
    else
        str={''};
    end
end

function t=i_blank
    t='<div>&nbsp;</div>';
end

function html=i_added(text)
    import com.mathworks.comparisons.util.ColorUtils;
    import com.mathworks.comparisons.prefs.TwoSourceColorProfile;
    rightColor=ColorUtils.getColor(TwoSourceColorProfile.RIGHT_DIFFERENCE_COLOR_NAME);

    html=i_getDivHTMLForColor(text,rightColor);
end

function html=i_removed(text)
    import com.mathworks.comparisons.util.ColorUtils;
    import com.mathworks.comparisons.prefs.TwoSourceColorProfile;
    leftColor=ColorUtils.getColor(TwoSourceColorProfile.LEFT_DIFFERENCE_COLOR_NAME);

    html=i_getDivHTMLForColor(text,leftColor);
end

function divHTML=i_getDivHTMLForColor(text,color)
    colorHTML=char(com.mathworks.comparisons.util.ColorUtils.colorToHTMLString(color));

    divHTML=['<div style="background: ',colorHTML,';">',text,'</div>'];
end

function t=i_unmodified(t)
    t=['<div>',t,'</div>'];
end

function html=i_modified(text)



    import com.mathworks.comparisons.util.ColorUtils;
    import com.mathworks.comparisons.prefs.TwoSourceColorProfile;
    color=ColorUtils.getColor(TwoSourceColorProfile.MODIFIED_LINE_COLOR_NAME);
    html=i_getDivHTMLForColor(text,color);
end

