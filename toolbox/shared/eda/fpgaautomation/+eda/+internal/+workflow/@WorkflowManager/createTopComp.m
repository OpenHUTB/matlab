function top=createTopComp(h,DUT,DCM)





    top=eda.internal.component.GenericTop;

    top.SimModel=[];
    top.UniqueName=[DUT.UniqueName,h.mWorkflowInfo.tdkParam.clkWrapperName];
    top.flatten=false;

    top.Partition.Name='top';
    top.Partition.Type='HW';
    top.Partition.Lang=h.mWorkflowInfo.hdlcData.target_language;


    top.component('Name',DCM.UniqueName,'Component',DCM);

    clk=top.signal('Name','clkdcm','FiType','boolean');

    dcmprops=properties(DCM);
    for ii=1:length(dcmprops)
        name=dcmprops{ii};
        np=copyPortFrom(top,DCM,name);
        if~isempty(np)
            if strcmpi(name,'clkout')
                DCM.(name).signal=clk;
                top.(name).signal=clk;
                top.setSignalSrcDst(struct(name,clk));
                top.assign(clk,top.(name));
            elseif isa(DCM.(name),'eda.internal.component.ResetPort')

                p=findprop(top,name);
                delete(p);
                newname=[name,'dcm'];
                top.addprop(newname);
                top.(newname)=np;
                top.(newname).UniqueName=newname;
                DCM.(name).signal=top.(newname);
            elseif isa(DCM.(name),'eda.internal.component.ClockPort')

                p=findprop(top,name);
                delete(p);
                newname=h.mWorkflowInfo.hdlcData.clockname;
                top.addprop(newname);
                top.(newname)=np;
                top.(newname).UniqueName=newname;
                DCM.(name).signal=top.(newname);
            else
                DCM.(name).signal=top.(name);
            end
        end
    end

    top.component('Name',DUT.Name,'Component',DUT);

    dutprops=properties(DUT);
    for ii=1:length(dutprops)
        name=dutprops{ii};
        if isa(DUT.(name),'eda.internal.component.ClockPort')
            DUT.(name).signal=clk;
            DUT.assign(clk,DUT.(name));
        else
            np=copyPortFrom(top,DUT,name);
            if~isempty(np)
                DUT.(name).signal=top.(name);
            end
        end
    end

end





function newport=copyPortFrom(this,oldcomp,name)
    if isa(oldcomp.(name),'eda.internal.component.Port')
        this.addprop(name);
        if isa(oldcomp.(name),'eda.internal.component.Inport')
            fitype=oldcomp.(name).FiType;
            this.(name)=eda.internal.component.Inport('FiType',fitype);
        elseif isa(oldcomp.(name),'eda.internal.component.ClockPort')
            this.(name)=eda.internal.component.ClockPort;
        elseif isa(oldcomp.(name),'eda.internal.component.ClockEnablePort')
            this.(name)=eda.internal.component.ClockEnablePort;
        elseif isa(oldcomp.(name),'eda.internal.component.ResetPort')
            this.(name)=eda.internal.component.ResetPort;
        elseif isa(oldcomp.(name),'eda.internal.component.Outport')
            fitype=oldcomp.(name).FiType;
            this.(name)=eda.internal.component.Outport('FiType',fitype);
        else
            error(message('EDALink:WorkflowManager:createTopComp:UnknownPortType',class(oldcomp.(name))));
        end
        this.(name).UniqueName=name;
        newport=this.(name);
    else
        newport=[];
    end
end
