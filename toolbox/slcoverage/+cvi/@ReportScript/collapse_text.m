function decData=collapse_text(decData)





    if all([decData.isActive])&&...
        (~isfield(decData,'collapseVector')||~any([decData.collapseVector]))
        return;
    end



    if(isfield(decData,'collapseVector'))
        [~,vecIdxs]=find([decData.collapseVector]);
        for idx=1:numel(vecIdxs)
            text=decData(vecIdxs(idx)).text;

            text=sprintf('%s%s%s%s',text,...
            '<span style=''color:red''>  <i>(',...
            getString(message('Slvnv:simcoverage:cvhtml:aggregated')),...
            '</i>)</span>');
            decData(vecIdxs(idx)).text=text;
        end
    end


    ranges=find_inactive_ranges([decData.isActive]);
    for idx=size(ranges,2):-1:1
        r1=ranges(1,idx);
        r2=ranges(2,idx)-1;
        if r1~=r2
            text=decData(r1).text;
            fs=num2str(r1);
            text=strrep(text,fs,[fs,'-',num2str(r2)]);
            decData(r1).text=text;
            decData(r1+1:r2)=[];
        end
    end

    function ranges=find_inactive_ranges(isActive)
        d=[1,isActive]-[isActive,1];
        [~,lr]=find(d>0);
        [~,rr]=find(d<0);
        ranges=[lr;rr];
