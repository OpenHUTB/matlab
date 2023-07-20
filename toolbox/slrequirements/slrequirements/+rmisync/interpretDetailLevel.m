function[filtAll,filtNone,filtMask,filtSf,filtSl,filtLeav]=interpretDetailLevel(detailLevelIndex)






























    sfisa=rmisf.sfisa;
    detailLevel=get_detail_level_label(detailLevelIndex);
    switch(detailLevel)
    case 'none'
        filtAll=true;
        filtNone=false;
        filtMask=false;
        filtLeav=false;
        filtSf=[];
        filtSl=[];

    case 'minimal'
        filtAll=false;
        filtNone=false;
        filtMask=true;
        filtLeav=true;
        filtSf=[sfisa.transition,sfisa.junction,sfisa.state];
        filtSl=[];

    case 'moderate'
        filtAll=false;
        filtNone=false;
        filtMask=true;
        filtLeav=true;
        filtSf=[sfisa.transition,sfisa.junction];
        filtSl=[];

    case 'average'
        filtAll=false;
        filtNone=false;
        filtMask=true;
        filtLeav=false;
        filtSf=[sfisa.transition,sfisa.junction];
        filtSl=get_trivial_block_types;

    case 'extensive'
        filtAll=false;
        filtNone=false;
        filtMask=true;
        filtLeav=false;
        filtSf=[];
        filtSl=[];

    case 'complete'
        filtAll=false;
        filtNone=true;
        filtMask=false;
        filtLeav=false;
        filtSf=[];
        filtSl=[];
    otherwise

    end

    function out=get_trivial_block_types
        out={'BusSelector','BusCreator','DataTypeConversion','From','Goto',...
        'Ground','Inport','Constant','GotoTagVisibility','Demux','Mux',...
        'Merge','BusAssignment','Outport','Terminator'};
    end

    function additionalDetail=get_detail_level_label(detailIdx)

        detailTable=get_details_setting_table();
        additionalDetail=detailTable{detailIdx,3};
    end

    function optionsTable=get_details_setting_table()

        optionsTable={...
        'None  (Recommended for better performance)',1,'none';...
        'Minimal   - Non-empty unmasked subsystems and Stateflow charts',2,'minimal';...
        'Moderate  - Unmasked subsystems, Stateflow charts, and superstates',3,'moderate';...
        'Average   - Nontrivial Simulink blocks, Stateflow charts and states',4,'average';...
        'Extensive - All unmasked blocks, subsystems, states and transitions',5,'extensive';...
        'Complete  - All blocks, subsystems, states and transitions',6,'complete'};
    end

end
