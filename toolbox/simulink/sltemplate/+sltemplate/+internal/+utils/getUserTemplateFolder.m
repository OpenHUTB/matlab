



function up=getUserTemplateFolder
    up=userpath;
    if isempty(up)

        up=pwd;
    end
end
