function dispFixptHelp(comp,fixptProps)



    if isempty(fixptProps)
        return;
    end

    showAllPropsLink=getString(message('MATLAB:system:ShowAllPropertiesText'));

    id=strfind(comp,'.');
    compCls=comp(id(end)+1:end);
    str={'   Fixed-point operations require a Fixed-Point Designer license.'};
    str{end+1}=['   Click the ''',showAllPropsLink,'''link to display fixed-point'];
    str{end+1}='   properties. Fixed-point properties are active if they appear ';
    str{end+1}='   in the longer display.';
    str{end+1}='';
    str{end+1}='   Fixed-point properties only affect System object operations when the ';
    str{end+1}='   object is processing fixed-point data.';
    str{end+1}='';
    str{end+1}=sprintf('   %s fixed-point properties:',compCls);
    str{end+1}='';


    maxlen=length(fixptProps{1});
    for ii=1:length(fixptProps)
        maxlen=max(maxlen,length(fixptProps{ii}));
    end
    for ii=1:length(fixptProps)
        hlp=evalc(['help ',comp,'.',fixptProps{ii}]);
        hlp=regexprep(hlp,'<[^>]*>','');
        inds=strfind(hlp,fixptProps{ii});
        indf=strfind(hlp,char(10));
        len=length(fixptProps{ii});


        numH1Lines=1;
        while numH1Lines<length(indf)
            hNext=hlp(indf(numH1Lines):indf(numH1Lines+1));

            if length(hNext)>=len&&all(isspace(hNext(1:len)))&&...
                ~all(isspace(hNext))
                numH1Lines=numH1Lines+1;
            else
                break;
            end
        end
        if matlab.internal.display.isHot
            linkStart=['<a href="matlab:help ',comp,'.',fixptProps{ii},'">'];
            linkEnd='</a>';
        else
            linkStart='';
            linkEnd='';
        end
        fixptPropH1=hlp(inds(1)+len+1:indf(numH1Lines)-1);
        fixptPropH1=strrep(fixptPropH1,char(10),[char(10),repmat(' ',1,maxlen-len+4)]);
        str{end+1}=['    ',linkStart,fixptProps{ii},linkEnd...
        ,repmat(' ',1,maxlen-len+1),'- ',fixptPropH1];%#ok<AGROW>
    end

    fprintf('%s\n',str{:});
    fprintf('\n');

end
