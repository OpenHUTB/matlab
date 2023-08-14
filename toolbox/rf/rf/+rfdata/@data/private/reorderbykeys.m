function data=reorderbykeys(h,data,formatline,keys,lnum,blocktype)





    numKeys=numel(keys);
    pos=cell(numKeys,1);
    for ii=1:numKeys
        pos{ii}=strfind(formatline,keys{ii});
        if~isscalar(pos{ii})
            error(message('rf:rfdata:data:reorderbykeys:keynotfound',lnum,keys{ii},blocktype));
        end
    end

    [temp,index]=sort(cell2mat(pos));


    temp=sortrows([index,data],1);
    data=temp(:,2:end).';