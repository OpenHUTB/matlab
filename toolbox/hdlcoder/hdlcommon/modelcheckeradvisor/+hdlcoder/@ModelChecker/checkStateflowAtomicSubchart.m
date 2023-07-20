function flag=checkStateflowAtomicSubchart(this)





    flag=true;
    model=this.m_sys;
    dut=this.m_DUT;
    rt=sfroot;
    m=rt.find('-isa','Simulink.BlockDiagram','-and','Name',model);
    charts=m.find('-isa','Stateflow.Chart');

    for i=1:length(charts)
        if isempty(regexp(charts(i).Path,sprintf('^%s/',dut),'once'))
            continue;
        end
        atomicSCharts=charts(i).find('-isa','Stateflow.AtomicSubchart','IsExplicitlyCommented',false,'IsImplicitlyCommented',false);
        if~isempty(atomicSCharts)
            for ii=1:numel(atomicSCharts)
                this.addCheck('warning',DAStudio.message('HDLShared:hdlmodelchecker:desc_atomic_subchart_unsupported'),[atomicSCharts(ii).Path,'/',atomicSCharts(ii).Name],0);
                flag=false;
            end
        end
    end
end
