function blocks=filterMathWorksBuiltInLibraryBlocks(blocks)






    if~iscell(blocks)
        assert(~isnumeric(blocks),'Handles not supported!');
        blocks={blocks};
    end

    r=get_param(blocks,'LinkStatus');
    i=find(ismember(r,'resolved'));
    mask=false(size(blocks));

    for k=1:numel(i)

        rb=get_param(blocks{i(k)},'ReferenceBlock');



        bdname=strtok(rb,'/');
        [~,inside_mlroot]=Simulink.loadsave.resolveFile(bdname);

        if inside_mlroot
            mask(i(k))=1;
        end
    end

    blocks(mask)=[];
end