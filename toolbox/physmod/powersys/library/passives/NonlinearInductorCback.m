function Icn=NonlinearInductorCback(block,Measurements)





    WantFlux=0;
    switch Measurements
    case 'Flux, Imag'
        if~isempty(find_system(bdroot(block),'LookUnderMasks','Functional','FollowLinks','on','MaskType','Multimeter'));
            WantFlux=1;
        end
    end
    HaveGotoBlock=strcmp(get_param([block,'/Flux'],'BlockType'),'Goto');
    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');
    if WantFlux&&~HaveGotoBlock
        replace_block(block,'Followlinks','on','Name','Flux','BlockType','Terminator','Goto','noprompt');
    end
    if~WantFlux&&HaveGotoBlock
        replace_block(block,'Followlinks','on','Name','Flux','BlockType','Goto','Terminator','noprompt');
    end
    if WantFlux
        SetNewGotoTag([block,'/Flux'],IsLibrary);
    end
    SetNewGotoTag([block,'/From'],IsLibrary);
    SetNewGotoTag([block,'/DSSout'],IsLibrary);
    SetNewGotoTag([block,'/Goto'],IsLibrary);
    Icn.x1=[
    150,173,173,174,178,184,190,196,202,206,207,207...
    ,207,207,208,212,218,224,230,236,240,241,241,241...
    ,241,242,246,252,258,264,270,274,275,275,300];
    Icn.y1=[
    0,0,1,11,19,24,25,24,19,11,1,0,0,1,11,19,24...
    ,25,24,19,11,1,0,0,1,11,19,24,25,24,19,11,1,0,0];
    Icn.x2=[30,47,55,61,67,83,89,95,103,120]+150;
    Icn.y2=[-37,-35,-32,-28,-20,20,28,32,35,37];