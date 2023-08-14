function isSF=isSFNetwork(~,slbh)



    isSF=slbh~=-1&&isprop(slbh,'BlockType')&&...
    strcmpi(get_param(slbh,'BlockType'),'SubSystem')&&...
    ~strcmpi(get_param(slbh,'SFBlockType'),'NONE');
end
