function addConnections(fid,src_dst_pairs)
    for i=1:2:numel(src_dst_pairs)
        fprintf(fid,'hsb_connect %s %s\n',src_dst_pairs{i},src_dst_pairs{i+1});
    end
end
