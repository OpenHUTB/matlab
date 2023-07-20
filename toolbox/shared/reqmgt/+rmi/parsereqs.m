function result=parsereqs(reqstr)



    result=[];

    if~isempty(reqstr)
        try
            [msg,reqs]=evalc(reqstr);
        catch Mex %#ok<NASGU>
            if strcmp(Mex.identifier,'MATLAB:m_unterminated_string')






                bad_chars=[11,12];
                replacements=[];
                for i=1:length(bad_chars)
                    bad_char=bad_chars(i);
                    if~isempty(strfind(reqstr,char(bad_char)))
                        reqstr=regexprep(reqstr,char(bad_char),sprintf('char(%d)',bad_char));
                        replacements(end+1)=bad_char;
                    end
                end

                try
                    [msg,reqs]=evalc(reqstr);



                    for i=1:length(replacements)
                        replacement_string=sprintf('char(%d)',replacements(i));
                        reqs{:,3}=strrep(reqs{:,3},replacement_string,eval(replacement_string));
                        if size(reqs,2)>4
                            reqs{:,5}=strrep(reqs{:,5},replacement_string,' ');
                        end
                    end
                catch Mex

                    return;
                end
            else
                return;
            end
        end
    else
        return;
    end

    if(isempty(reqs)||~iscell(reqs))
        return;
    end


    [rowCount,colCount]=size(reqs);

    if colCount<3
        return;
    end



    if colCount<6
        keywords={''};
    else
        keywords=reqs(:,6);
    end

    if colCount<5

        descriptions=reqs(:,3);
    else
        descriptions=reqs(:,5);
    end

    if colCount<4
        linked={false};
    else
        linked=num2cell(strcmp(reqs(:,4),'true'));
    end

    result=rmi.reqstruct(reqs(:,2),...
    reqs(:,3),...
    descriptions,...
    keywords,...
    linked,...
    reqs(:,1));

