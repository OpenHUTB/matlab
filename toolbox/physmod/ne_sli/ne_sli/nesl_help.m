function link=nesl_help(block)













    narginchk(1,1);

    link=pmsl_help(block);
    if isempty(link)




        LINK_ID='language_block_help';
        link=matlab.internal.doc.csh.mapTopic('simscape',LINK_ID);
    end

end
