function data=reorderdata(keys,data,formatline)

























    narginchk(3,3);


    formatline=strtrim(formatline);


    if~isequal(formatline(1),'%')

        error(message('rf:rffile:shared:sandp2d:reorderdata:MissingPercentageSign'))
    end
    formatline_no_percent=strrep(upper(formatline(2:end)),' ','');


    if~isequal(length(formatline_no_percent),sum(cellfun(@length,keys)))

        error(message('rf:rffile:shared:sandp2d:reorderdata:ErrorFormatLine'))
    end


    numKeys=numel(keys);
    pos=zeros(numKeys,1);



    [~,descendidx]=sort(cellfun(@length,keys),'descend');

    for ii=1:numKeys
        temppos=strfind(formatline_no_percent,upper(keys{descendidx(ii)}));
        if~isscalar(temppos)

            error(message('rf:rffile:shared:sandp2d:reorderdata:ErrorFormatLine'))
        end
        pos(ii)=temppos;

        keylength=length(keys{descendidx(ii)});



        formatline_no_percent(temppos:temppos+keylength-1)=blanks(keylength);

    end


    [~,index]=sort(pos);


    temp=sortrows([descendidx(index).',data.'],1);
    data=temp(:,2:end).';