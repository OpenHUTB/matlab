function optionsTable=cv_dialog_options(varargin)











    optionsTable={...
    DAStudio.message('Slvnv:simcoverage:logicBlkShortcircuit'),...
    's',...
    0,...
    'logicBlkShortcircuit';...
    DAStudio.message('Slvnv:simcoverage:checkUnsupportedBlocks'),...
    'w',...
    1,...
    'checkUnsupportedBlocks';...
    DAStudio.message('Slvnv:simcoverage:forceBlockReductionOff'),...
    'f',...
    1,...
'forceBlockReductionOff'...
    };


    if(nargin==2)
        switch(varargin{1})
        case 'enabledTags'
            settingStr=varargin{2};
            optionsTable=abbrev_to_index(settingStr,optionsTable);
        end
    end

    function options=abbrev_to_index(abbrev,optionsTable)
        [r,~]=size(optionsTable);
        options=cell(r,3);
        for j=1:r
            options{j,1}=optionsTable{j,2};
            options{j,2}=~isempty(findstr(abbrev,optionsTable{j,2}));
            options{j,3}=optionsTable{j,4};
        end




