function RawfileOrSPICEPath(modelName)





    blockName=[modelName,'/Parameters'];
    stringInput=get_param(blockName,'RawfileOrSPICEPath');
    maskNames=get_param(blockName,'MaskNames');
    visibility=cell(1,length(maskNames));
    for ii=1:length(maskNames)
        if(strcmp(maskNames{ii},'Rawfile')&&strcmp(stringInput,'SPICEPath'))...
            ||(strcmp(stringInput,'Rawfile')&&strcmp(maskNames{ii},'SPICEPath'))
            visibility{ii}='off';
        else
            visibility{ii}='on';
        end
    end
    set_param(blockName,'MaskVisibilities',visibility);
end