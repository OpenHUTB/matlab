function AvmInverterCbak(block)










    try

        arms=get_param(block,'Arms');


        device=get_param(block,'Device');


        measurements=get_param(block,'Measurements');


        mv=get_param([block,'/Universal Bridge'],'Maskvisibilities');
        mv_old=get_param(block,'Maskvisibilities');

        mv_new=mv_old;

        mv_new(1:length(mv)-1)=mv(1:end-1);
    catch
        m{1}='Unable to get the parameters of the Universal Bridge block';
        m{2}='Please contact help support.';
        msgbox(m,'Detailed inverter','error')
        return
    end

    try
        set_param([block,'/Universal Bridge'],'Arms',arms)
        set_param([block,'/Universal Bridge'],'Device',device)
        set_param([block,'/Universal Bridge'],'Measurements',measurements)

        set_param(block,'Maskdisplay',get_param([block,'/Universal Bridge'],'Maskdisplay'))
        set_param(block,'Maskvisibilities',mv_new)
    catch
        m{1}='Unable to set the parameters of the Universal Bridge block';
        m{2}='Please contact help support.';
        msgbox(m,'Detailed inverter','error')
        return
    end
