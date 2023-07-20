function flag=checkMLFcnBlkSatInt(this)




    flag=true;

    model=this.m_sys;
    rt=sfroot;
    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    emchart=m.find('-isa','Stateflow.EMChart');

    for i=1:numel(emchart)
        if emchart(i).SaturateOnIntegerOverflow


            this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_Saturate_Int_Overflow'),emchart(i).Path,0);
            flag=false;
        end
    end
end
