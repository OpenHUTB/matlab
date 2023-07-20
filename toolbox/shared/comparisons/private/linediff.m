function[newline1,newline2]=linediff(line1,line2,padlength,ignore_whitespace)










    if nargin<4
        ignore_whitespace=false;
        if nargin<3
            padlength=inf;
        end
    end
    tok1=tokenize(line1,ignore_whitespace);
    tok2=tokenize(line2,ignore_whitespace);
    [align1,align2]=diffcode(tok1(:,2),tok2(:,2));
    [differ1,differ2]=compareTokens(align1,align2,tok1,tok2);
    if ignore_whitespace


        is_whitespace_1=find(tok1(:,2)==hash(' '));
        is_whitespace_2=find(tok2(:,2)==hash(' '));

        differ1=differ1(~ismember(differ1,is_whitespace_1));
        differ2=differ2(~ismember(differ2,is_whitespace_2));
    end
    newline1=formatLine(line1,differ1,tok1(:,1),padlength);
    newline2=formatLine(line2,differ2,tok2(:,1),padlength);

end







function newl=formatLine(l1,colorize,toks,padlength)
    charcount=0;
    outc=cell(numel(toks),1);

    import com.mathworks.comparisons.util.ColorUtils;
    import com.mathworks.comparisons.prefs.TwoSourceColorProfile;
    color=ColorUtils.getColor(TwoSourceColorProfile.MODIFIED_CONTENT_COLOR_NAME);
    color=ColorUtils.colorToHTMLString(color);
    for k=1:numel(toks)
        if k==numel(toks)
            tok_end=numel(l1);
        else
            tok_end=toks(k+1)-1;
        end
        tt=replacetabs(l1(toks(k):tok_end),charcount);
        charcount=charcount+numel(tt);
        if charcount>padlength
            chop=charcount-padlength;
            tt(end-chop+1:end)=[];
        end
        tt=code2html(tt);
        if ismember(k,colorize)
            prepend='';
            if~ismember(k-1,colorize)

                prepend=['<span style="background: ',char(color),';">'];
            end
            append='';
            if~ismember(k+1,colorize)||charcount>=padlength

                append='</span>';
            end
            outc{k}=sprintf('%s%s%s',prepend,tt,append);
        else
            outc{k}=tt;
        end
        if charcount>=padlength
            break;
        end
    end
    newl=char([outc{:}]);
    if charcount<padlength&&isfinite(padlength)
        extra=padlength-charcount;
        newl=[newl,repmat(char(32),1,extra)];
    end
end







function[differ1,differ2]=compareTokens(align1,align2,tok1,tok2)

    removed1=align2==0;
    removed2=align1==0;


    possible_differ=~removed1&~removed2;
    atok1=align1;
    atok1(possible_differ)=tok1(align1(possible_differ),2);
    atok1(~possible_differ)=0;
    atok2=align2;
    atok2(possible_differ)=tok2(align2(possible_differ),2);
    atok2(~possible_differ)=0;
    act_differ=atok1~=atok2;


    differ1=align1(removed1|act_differ);
    differ2=align2(removed2|act_differ);

end



function h=hash(s)
    h=0;
    for k=1:length(s)
        sk=s(k);
        c=-1.85-1/sk;
        h=h*h+c;
    end
end









function t=tokenize(s,ignore_whitespace)
    persistent tok_class;
    if isempty(tok_class)
        tok_class=zeros(1,127);
        tok_class(double('A':'Z'))=1;
        tok_class(double('a':'z'))=1;
        tok_class(double('0':'9'))=1;
        tok_class('_')=1;
        tok_class(' ')=2;
        tok_class(9)=2;
    end
    if isempty(s)


        t=zeros(0,2);
        return;
    end
    s(s>127)='a';
    cls=tok_class(double(s));

    symbols=find(cls==0);
    cls(symbols)=100+(1:length(symbols));


    [~,pos]=find(diff(cls));
    pos=[1,pos+1,length(s)+1];
    t=zeros(length(pos)-1,2);
    for k=1:length(pos)-1
        word=s(pos(k):(pos(k+1)-1));
        if ignore_whitespace

            if cls(pos(k))==2
                word=' ';
            end
        end
        t(k,:)=[pos(k),hash(word)];
    end
end

