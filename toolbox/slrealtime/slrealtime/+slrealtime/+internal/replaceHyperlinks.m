function new_msg=replaceHyperlinks(msg)











    new_msg=msg;





    while true
        idxs=regexp(new_msg,'(<a\s*href[^>]*>\s*)([^<]*)(</a>)',...
        'tokenExtents','once');

        if isempty(idxs),break;end

        assert(all(size(idxs)==[3,2]));

        new_msg=strrep(new_msg,...
        new_msg(idxs(1,1):idxs(3,2)),...
        new_msg(idxs(2,1):idxs(2,2)));
    end
end
