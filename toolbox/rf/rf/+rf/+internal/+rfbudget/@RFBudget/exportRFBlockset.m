function out=exportRFBlockset(obj,modelName,freqdelta)




    if~obj.Computable
        out=[];
        return
    end
    v=ver;
    installedProducts={v(:).Name};
    haveSimulink=builtin('license','test','SIMULINK')&&...
    any(strcmp('Simulink',installedProducts));
    haveRFBlockset=builtin('license','test','RF_Blockset')&&...
    any(strcmp('RF Blockset',installedProducts));
    if~haveSimulink||~haveRFBlockset
        error(message('rf:rfbudget:NeedRFBLKS'))
    end

    load_system('simulink')
    load_system('simrfV2elements')
    load_system('simrfV2util1')
    load_system('simrfV2sources1')
    load_system('simrfV2systems')
    load_system('rfBudgetAnalyzer_lib')

    x=100;
    y=150;
    dx=40;
    dy=100;



    freqIdx=1;
    InputFreq=obj.InputFrequency(freqIdx);
    OutputFreqs=obj.OutputFrequency(freqIdx,:);


    inputIQ=(InputFreq==0);
    outputIQ=(OutputFreqs(end)==0);
    inOrOutputIQ=(inputIQ||outputIQ);

    if nargin<2
        h=new_system('','model');
        modelName=get(h,'Name');
        set_param(modelName,'StopTime','0')


        freqdelta=0;

        PA=zeros(1,length(obj.Elements));
        for i=1:length(obj.Elements)
            PA(i)=isa(obj.Elements(i),'powerAmplifier');
        end
        if any(PA)
            error(message('rf:shared:RFBlocksetExport'))
        end

        Rx=0;
        if isa(obj.Elements(1),'rfantenna')
            if strcmpi(obj.Elements(1).Type,'Receiver')
                Rx=1;
                InputPower=obj.AvailableInputPower-obj.Elements(1).Gain;
            else
                InputPower=obj.AvailableInputPower;
            end
        else
            InputPower=obj.AvailableInputPower;
        end
        src='simulink/Sources/Constant';
        p=get_param(src,'Position');
        pos=obj.newPos(p,x,y+inOrOutputIQ*0.6*dy/2);
        h=add_block(src,...
        sprintf('%s/Available\ninput power\n(dBm)',modelName),'Position',pos);
        set(h,'Value',sprintf('%.15g',InputPower));
        ph=get(h,'PortHandles');
        outport=ph.Outport;
        input=outport;
        x=pos(3)+dx;

        if inputIQ
            PhaseStr='0[Deg] phase';
            src='rfBudgetAnalyzer_lib/dBm to Linear';
        else
            PhaseStr='45[Deg] phase';
            src=sprintf(['rfBudgetAnalyzer_lib/dBm to Linear\n',PhaseStr]);
        end
        p=get_param(src,'Position');
        pos=obj.newPos(p,x,y+inOrOutputIQ*0.6*dy/2);
        h=add_block(src,sprintf(['%s/dBm to Linear\n',PhaseStr],modelName),...
        'Position',pos);
        ph=get(h,'PortHandles');
        add_line(modelName,outport,ph.Inport,'autorouting','on')
        outport=ph.Outport;
        x=pos(3)+dx;

        if Rx
            freq=InputFreq;
            elem=obj.Elements(1);
            [x,rconn]=rbBlocks(elem,modelName,x,...
            y+(nargin<2)*inOrOutputIQ*0.6*dy/2,...
            dx,dy,outport,freq,obj,1,freqdelta,freqIdx);
            if inputIQ
                [x,rconn(2)]=rbBlocks(elem,modelName,x-(pos(3)-2.7*dx),...
                y+dy*(0.6+2)/2,...
                dx,dy,outport,freq,obj,1,freqdelta,freqIdx);
            end
        else
            [freq,~,freq_prefix]=obj.engunitsGLimited(InputFreq);
            src='simrfV2util1/Inport';
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-inputIQ)*dy/2);
            h=add_block(src,[modelName,'/Inport1'],'Position',pos);
            set(h,...
            'SimulinkInputSignalType','Power',...
            'CarrierFreq',sprintf('%.15g',freq),...
            'CarrierFreq_unit',[freq_prefix,'Hz'],...
            'ZS','50');
            ph=get(h,'PortHandles');
            rconn(1)=ph.RConn;
            add_line(modelName,outport,ph.Inport,'autorouting','on')
            if inputIQ
                p=get_param(src,'Position');
                pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
                h=add_block(src,[modelName,'/Inport2'],'Position',pos);
                set(h,...
                'SimulinkInputSignalType','Power',...
                'CarrierFreq',sprintf('%.15g',freq),...
                'CarrierFreq_unit',[freq_prefix,'Hz'],...
                'ZS','50');
                ph=get(h,'PortHandles');
                rconn(2)=ph.RConn;
                add_line(modelName,outport,ph.Inport,'autorouting','on')
            end

        end
        src='simrfV2util1/Configuration';
        p=get_param(src,'Position');
        pos=obj.newPos(p,x,y-dy+(inOrOutputIQ*0.6-inputIQ)*dy/2);
        h=add_block(src,[modelName,'/Configuration1'],'Position',pos);
        set(h,...
        'AutoFreq','on',...
        'NormalizeCarrierPower','on',...
        'StepSize',['(1/',sprintf('%.15g',obj.SignalBandwidth),')/8'],...
        'StepSize_unit','s',...
        'AddNoise','on',...
        'Orientation','left')
        ph=get(h,'PortHandles');
        add_line(modelName,rconn(1),ph.LConn,'autorouting','on')


        if inputIQ&&all(OutputFreqs==0)
            pos=obj.newPos(p,x,y+dy+dy*(0.6+1)/2);
            h=add_block(src,[modelName,'/Configuration2'],...
            'Position',pos);
            set(h,...
            'AutoFreq','on',...
            'NormalizeCarrierPower','on',...
            'StepSize',['(1/',sprintf('%.15g',obj.SignalBandwidth),')/8'],...
            'StepSize_unit','s',...
            'AddNoise','on',...
            'Orientation','left')
            ph=get(h,'PortHandles');
            add_line(modelName,rconn(2),ph.LConn,'autorouting','on')
        end
        x=pos(3)+dx;
        if~Rx
            src='simrfV2sources1/Noise';
            p=[0,0,50,50];
            pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-inputIQ)*dy/2);
            h=add_block(src,sprintf('%s/Thermal Noise1',modelName),'Position',pos);
            set(h,...
            'InternalGrounding','off',...
            'Orientation','left',...
            'SimulinkInputSignalType','Ideal voltage',...
            'NoiseType','White',...
            'NoisePSD','4*rf.physconst(''Boltzmann'')*290*50');
            set(h,'Position',pos);

            ph=get(h,'PortHandles');
            add_line(modelName,rconn(1),ph.RConn,'autorouting','on')
            rconn(1)=ph.LConn;
            if inputIQ
                pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
                h=add_block(src,sprintf('%s/Thermal Noise2',modelName),'Position',pos);
                set(h,...
                'InternalGrounding','off',...
                'Orientation','left',...
                'SimulinkInputSignalType','Ideal voltage',...
                'NoiseType','White',...
                'NoisePSD','4*rf.physconst(''Boltzmann'')*290*50');
                set(h,'Position',pos);

                ph=get(h,'PortHandles');














                add_line(modelName,rconn(2),ph.RConn,'autorouting','on')
                rconn(2)=ph.LConn;
            end
            x=pos(3)+dx;
        end
    else
        if inputIQ
            src=[modelName,'/InI'];
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y-dy/2);
            set_param(src,'Position',pos)
            ph=get_param(src,'PortHandles');
            rconn(1)=ph.RConn;
            src=[modelName,'/InQ'];
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+dy/2);
            set_param(src,'Position',pos)
            ph=get_param(src,'PortHandles');
            rconn(2)=ph.RConn;
            x=pos(3)+dx;
        else
            src=[modelName,'/In'];
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y);
            set_param(src,'Position',pos)
            ph=get_param(src,'PortHandles');
            rconn=ph.RConn;
            x=pos(3)+dx;
        end
    end



    writeMissingNportFiles(obj)
    freq=InputFreq;
    moreYSpace=false;
    for i=1:numel(obj.Elements)
        if isa(obj.Elements(i),'rfantenna')&&i==1
            if numel(obj.Elements)>1&&~strcmpi(obj.Elements(i).Type,'TransmitReceive')
                continue;
            elseif Rx
                break;
            end
        end
        elem=obj.Elements(i);
        [x,rconn]=rbBlocks(elem,modelName,x,...
        y+(nargin<2)*inOrOutputIQ*0.6*dy/2,...
        dx,dy,rconn,freq,obj,i,freqdelta,freqIdx);
        if freq==0&&~isa(elem,'modulator')
            moreYSpace=true;
        end
        freq=OutputFreqs(i);
    end

    if nargin<2
        ant=zeros(1,length(obj.Elements),'logical');
        for i=1:length(obj.Elements)
            ant(i)=isa(obj.Elements(i),'rfantenna');
        end
        if any(ant)
            if strcmpi(obj.Elements(ant).Type,'TransmitReceive')
                Rx=1;
                src='simrfV2util1/Configuration';
                p=get_param(src,'Position');
                pos=obj.newPos(p,x,y-dy+(inOrOutputIQ*0.6-inputIQ)*dy/2);
                h=add_block(src,[modelName,'/Configuration'],'Position',pos,'MakeNameUnique','on');
                set(h,...
                'AutoFreq','on',...
                'NormalizeCarrierPower','on',...
                'StepSize',['(1/',sprintf('%.15g',obj.SignalBandwidth),')/8'],...
                'StepSize_unit','s',...
                'AddNoise','on',...
                'Orientation','right')
                ph=get(h,'PortHandles');
                add_line(modelName,rconn(1),ph.LConn,'autorouting','on')
                if all(OutputFreqs(find(ant):end)==0)
                    pos=obj.newPos(p,x,y+dy+dy*(0.6+1)/2);
                    h=add_block(src,[modelName,'/Configuration'],...
                    'Position',pos,'MakeNameUnique','on');
                    set(h,...
                    'AutoFreq','on',...
                    'NormalizeCarrierPower','on',...
                    'StepSize',['(1/',sprintf('%.15g',obj.SignalBandwidth),')/8'],...
                    'StepSize_unit','s',...
                    'AddNoise','on',...
                    'Orientation','right')
                    ph=get(h,'PortHandles');
                    add_line(modelName,rconn(2),ph.LConn,'autorouting','on')
                end
            end
        end
        if~any(ant)||Rx
            src='simrfV2util1/Outport';
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-outputIQ)*dy/2);
            h=add_block(src,[modelName,'/Outport1'],'Position',pos);
            [freq,~,freq_prefix]=obj.engunitsGLimited(abs(OutputFreqs(:,end)));
            set(h,...
            'SensorType','Power',...
            'CarrierFreq',sprintf('%.15g',freq),...
            'CarrierFreq_unit',[freq_prefix,'Hz'],...
            'ZL','50');
            ph=get(h,'PortHandles');
            add_line(modelName,rconn(1),ph.LConn,'autorouting','on')

            outport(1)=ph.Outport;
            if outputIQ
                pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
                h=add_block(src,[modelName,'/Outport2'],'Position',pos);
                set(h,...
                'SensorType','Power',...
                'CarrierFreq',sprintf('%.15g',freq),...
                'CarrierFreq_unit',[freq_prefix,'Hz'],...
                'ZL','50');
                ph=get(h,'PortHandles');
                add_line(modelName,rconn(2),ph.LConn,'autorouting','on')
                outport(2)=ph.Outport;
            end
            x=pos(3)+dx;
        else
            outport(1)=rconn(1);
            if outputIQ
                outport(2)=rconn(2);
            end
        end

        if any(ant)&&~Rx
            src='rfBudgetAnalyzer_lib/EIRPCalculation';
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-outputIQ)*dy/2);
            h=add_block(src,sprintf('%s/EIRP Calculation',modelName),'Position',pos);
            ph=get(h,'PortHandles');
            add_line(modelName,outport(1),ph.Inport,'autorouting','on')
            outport(1)=ph.Outport;
            if outputIQ
                pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
                h=add_block(src,sprintf('%s/EIRP Calculation2',modelName),'Position',pos);
                ph=get(h,'PortHandles');
                add_line(modelName,outport(2),ph.Inport,'autorouting','on')
                outport(2)=ph.Outport;
            end
        else
            src='rfBudgetAnalyzer_lib/Linear to dBm';
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-outputIQ)*dy/2);
            h=add_block(src,sprintf('%s/Linear to dBm1',modelName),'Position',pos);
            ph=get(h,'PortHandles');
            add_line(modelName,outport(1),ph.Inport,'autorouting','on')
            outport(1)=ph.Outport;
            if outputIQ
                pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
                h=add_block(src,sprintf('%s/Linear to dBm2',modelName),'Position',pos);
                ph=get(h,'PortHandles');
                add_line(modelName,outport(2),ph.Inport,'autorouting','on')
                outport(2)=ph.Outport;
            end

        end
        x=pos(3)+dx;

        src='simulink/Sinks/Display';
        p=get_param(src,'Position');
        pos=obj.newPos(p,x+(~inOrOutputIQ)*1.5*dx,y+(inOrOutputIQ*0.6-outputIQ)*dy/2);
        h=add_block(src,sprintf('%s/Output power (dBm)1',modelName),'Position',pos);
        ph=get(h,'PortHandles');
        add_line(modelName,outport(1),ph.Inport,'autorouting','on')
        if outputIQ
            pos=obj.newPos(p,x,y+dy*(0.6+1)/2);
            h=add_block(src,...
            sprintf('%s/Output power (dBm)2',modelName),'Position',pos);
            ph=get(h,'PortHandles');
            add_line(modelName,outport(2),ph.Inport,'autorouting','on')
        end

        if~inOrOutputIQ&&(Rx||~any(ant))
            src='simulink/Math Operations/Subtract';
            p=get_param(src,'Position');
            x=pos(1)-dx-(p(3)-p(1));
            pos=obj.newPos(p,x,y+dy+moreYSpace*dy/2);
            h=add_block(src,sprintf('%s/Subtract',modelName),'Position',pos);
            ph=get(h,'PortHandles');
            add_line(modelName,outport,ph.Inport(1),'autorouting','on')
            add_line(modelName,input,ph.Inport(2),'autorouting','on')
            outport=ph.Outport;
            x=pos(3)+dx;

            src='simulink/Sinks/Display';
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+dy+moreYSpace*dy/2);
            h=add_block(src,...
            sprintf('%s/Transducer gain (dB)',modelName),'Position',pos);
            ph=get(h,'PortHandles');
            add_line(modelName,outport,ph.Inport,'autorouting','on')
        end
    else
        if outputIQ
            src=[modelName,'/OutI'];
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y-dy/2);
            set_param(src,'Position',pos)
            ph=get_param(src,'PortHandles');
            add_line(modelName,rconn(1),ph.RConn,'autorouting','on')
            src=[modelName,'/OutQ'];
            p=get_param(src,'Position');
            pos=obj.newPos(p,x,y+dy/2);
            set_param(src,'Position',pos)
            ph=get_param(src,'PortHandles');
            add_line(modelName,rconn(2),ph.RConn,'autorouting','on')
        else
            ant=zeros(1,length(obj.Elements));
            for i=1:length(obj.Elements)
                ant(i)=isa(obj.Elements(i),'rfantenna');
            end
            if~any(ant)
                src=[modelName,'/Out'];
                p=get_param(src,'Position');
                pos=obj.newPos(p,x,y);
                set_param(src,'Position',pos)
                ph=get_param(src,'PortHandles');
                add_line(modelName,rconn,ph.RConn,'autorouting','on')
            else
                [freq,~,freq_prefix]=obj.engunitsGLimited(InputFreq);
                src='simrfV2util1/Inport';
                p=get_param(src,'Position');
                pos=obj.newPos(p,x,y+(inOrOutputIQ*0.6-inputIQ)*dy/2);
                h=add_block(src,[modelName,'/Inport1'],'Position',pos);
                set(h,...
                'SimulinkInputSignalType','Power',...
                'CarrierFreq',sprintf('%.15g',freq),...
                'CarrierFreq_unit',[freq_prefix,'Hz'],...
                'ZS','50');
                ph=get(h,'PortHandles');
                rconn1(1)=ph.RConn;
                add_line(modelName,rconn,ph.Inport,'autorouting','on')
                src=[modelName,'/Out'];
                p=get_param(src,'Position');
                pos=obj.newPos(p,x,y+dy);
                set_param(src,'Position',pos)
                ph=get_param(src,'PortHandles');
                add_line(modelName,rconn1,ph.RConn,'autorouting','on')
            end
        end
    end
    set_param(modelName,'ZoomFactor','100')

    if nargout>0
        out=modelName;
    else
        open_system(modelName)
    end
