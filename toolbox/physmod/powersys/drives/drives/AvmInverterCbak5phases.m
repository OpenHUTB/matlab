function AvmInverterCbak5phases(block)











    arms=get_param(block,'Arms');


    device=get_param(block,'Device');


    measurements=get_param(block,'Measurements');


    mv=get_param([block,'/Universal Bridge'],'Maskvisibilities');
    mv_old=get_param(block,'Maskvisibilities');

    mv_new=mv_old;
    mv_new(1:length(mv)-1)=mv(1:end-1);

    set_param([block,'/Universal Bridge'],'Arms',arms)
    set_param([block,'/Universal Bridge'],'Device',device)
    set_param([block,'/Universal Bridge'],'Measurements',measurements)
    set_param([block,'/Universal Bridge1'],'Arms',arms)
    set_param([block,'/Universal Bridge1'],'Device',device)
    set_param([block,'/Universal Bridge1'],'Measurements',measurements)
    set_param([block,'/Universal Bridge2'],'Arms',arms)
    set_param([block,'/Universal Bridge2'],'Device',device)
    set_param([block,'/Universal Bridge2'],'Measurements',measurements)
    set_param([block,'/Universal Bridge3'],'Arms',arms)
    set_param([block,'/Universal Bridge3'],'Device',device)
    set_param([block,'/Universal Bridge3'],'Measurements',measurements)
    set_param([block,'/Universal Bridge4'],'Arms',arms)
    set_param([block,'/Universal Bridge4'],'Device',device)
    set_param([block,'/Universal Bridge4'],'Measurements',measurements)


    set_param(block,'Maskdisplay',get_param([block,'/Universal Bridge'],'Maskdisplay'))
    set_param(block,'Maskvisibilities',mv_new)
