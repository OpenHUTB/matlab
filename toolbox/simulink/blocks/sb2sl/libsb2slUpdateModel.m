function libsb2slUpdateModel(h)







    ReplaceInfo={...
    {'ReferenceBlock','libsb2sl/LOG/NOT'},'Replacelibsb2slBlocks';...
    {'ReferenceBlock','libsb2sl/LOG/EQV'},'Replacelibsb2slBlocks';...
    {'ReferenceBlock','libsb2sl/LOG/NEQV'},'Replacelibsb2slBlocks';...
    {'ReferenceBlock','libsb2sl/LOG/Switch'},'Replacelibsb2slBlocks'};

    ReplaceInfo=cell2struct(ReplaceInfo,{'BlockDesc','ReplaceFcn'},2);
    replaceBlocks(h,ReplaceInfo);
