function s=encodeURIComponent(s)
    s=unicode2native(s,'UTF-8');

    i_special_ascii=(s=='\')|(s=='/')|(s=='%')|(s=='"')|...
    (s=='*')|(s==':')|(s=='<')|(s=='>')|...
    (s=='?')|(s=='#')|(s=='$')|(s=='&')|...
    (s=='+')|(s==',')|(s==';')|(s=='=')|...
    (s=='@')|(s=='[')|(s==']')|(s=='^')|...
    (s=='`')|(s=='{')|(s=='|')|(s=='}');
    i_normal_ascii=(s>32)&(s<127)&~i_special_ascii;

    t=cell(1,length(s));

    s1=s(i_normal_ascii);
    t1=cell(1,length(s1));
    for ii=1:numel(s1)
        t1{ii}=s1(ii);
    end
    t(i_normal_ascii)=t1;

    t(~i_normal_ascii)=arrayfun(@encode_byte,s(~i_normal_ascii),'UniformOutput',false);

    s=char([t{:}]);
end


function c=encode_byte(c)
    c=[uint8('%'),uint8(sprintf('%02X',c))];
end
