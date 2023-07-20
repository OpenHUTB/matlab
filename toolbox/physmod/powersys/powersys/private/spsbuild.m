function spsbuild(sps,NetworkNumber,SPECIALCIRCUIT)






    if~strcmp(get_param(sps.PowerguiInfo.BlockName,'linkstatus'),'inactive')
        set_param(sps.PowerguiInfo.BlockName,'linkstatus','inactive');
    end


    load_system('power_utile');



    HAVEINPUTS=~isempty(sps.U.Mux);
    YOUT=~isempty(sps.Y.Demux);

    if sps.PowerguiInfo.Continuous

        if sps.SwitchDevices.qty

            if isempty(sps.U.Mux)

                Model='power_utile/Continuous NoSources';
                MUXU=0;
                SWC=1;
            else

                Model='power_utile/Continuous';
                MUXU=1;
                SWC=1;
            end
            SWITCHES=1;
        elseif sps.SwitchDevices.total

            Model='power_utile/Continuous NoSingleSwitch';
            MUXU=0;
            SWC=0;
            SWITCHES=1;
        elseif sps.SwitchDevices.total==0&&HAVEINPUTS


            Model='power_utile/NoSwitch Continuous';
            MUXU=0;
            SWC=0;
            SWITCHES=0;


            if sps.NbMachines==0&&isempty(sps.SaturableTransfo)&&isempty(sps.Flux.Mux)
                Model='power_utile/NoSwitch Continuous SSB';
            end
        else

            Model='power_utile/NoSwitch NoSource Continuous';
            MUXU=0;
            SWC=0;
            SWITCHES=0;
        end
    end

    if sps.PowerguiInfo.Discrete

        ModeDiscret='Discrete';
        if sps.SwitchDevices.qty

            if isempty(sps.U.Mux)

                Model=['power_utile/',ModeDiscret,' NoSources'];
                MUXU=0;
                SWC=1;
            else

                Model=['power_utile/',ModeDiscret];
                MUXU=1;
                SWC=1;
            end
            SWITCHES=1;
        elseif sps.SwitchDevices.total

            Model=['power_utile/',ModeDiscret,' NoSingleSwitch'];
            MUXU=0;
            SWC=0;
            SWITCHES=1;
        elseif sps.SwitchDevices.total==0&&HAVEINPUTS


            if~isempty(sps.BridgeSrcV)&&sps.PowerguiInfo.Interpolate

                Model=['power_utile/',ModeDiscret,' NoSingleSwitch'];
                MUXU=0;
                SWC=0;
                SWITCHES=1;
            else
                Model=['power_utile/NoSwitch ',ModeDiscret];
                MUXU=0;
                SWC=0;
                SWITCHES=0;
            end
        else

            Model=['power_utile/NoSwitch NoSource ',ModeDiscret];
            MUXU=0;
            SWC=0;
            SWITCHES=0;
        end
    end

    if sps.PowerguiInfo.Phasor

        if sps.SwitchDevices.qty

            if isempty(sps.U.Mux)

                Model='power_utile/Phasors NoSources';
                MUXU=0;
                SWC=1;
            else

                Model='power_utile/Phasors';
                MUXU=1;
                SWC=1;
            end
            SWITCHES=1;
        else


            Model='power_utile/NoSwitch Phasors';
            MUXU=0;
            SWC=0;
            SWITCHES=0;
        end
    end

    if sps.PowerguiInfo.DiscretePhasor

        if sps.SwitchDevices.qty
            if isempty(sps.DSS.block)
                Model='power_utile/DiscretePhasors noDSSin';
            else
                Model='power_utile/DiscretePhasors';
            end
            MUXU=1;
            SWC=1;
            SWITCHES=1;
        else


            if isempty(sps.DSS.block)
                Model='power_utile/NoSwitch DiscretePhasors noDSSin';
            else
                Model='power_utile/NoSwitch DiscretePhasors';
            end
            MUXU=0;
            SWC=0;
            SWITCHES=0;
        end

    else

        if~isempty(sps.Flux.Tags)
            FLUX=1;
            Model=[Model,' Flux'];
        else
            FLUX=0;
        end

        WantDSS=0;
        if sps.PowerguiInfo.WantDSS

            if isempty(sps.DSS.block)



            else

                Model=[Model,' DSS'];
                WantDSS=1;
            end
        else


            if~isempty(sps.DSS.block)

                Model=[Model,' DSS'];
                WantDSS=1;
            end
        end

    end

    DummyCircuit=0;
    DummyFromsGotos=0;
    DummyGotos=0;

    if exist('SPECIALCIRCUIT','var')
        switch SPECIALCIRCUIT
        case 'SimpleMatrixGainBlock'

            Model='power_utile/SimpleMatrixGainBlock';
            DummyCircuit=1;
        case 'DummyFroms'

            Model='power_utile/DummyFroms';
            DummyCircuit=1;
        case 'DummyFromsGotos'

            Model='power_utile/DummyFromsGotos';
            DummyFromsGotos=1;
            DummyCircuit=1;
        case 'DummyGotos'

            Model='power_utile/DummyGotos';
            DummyGotos=1;
            DummyCircuit=1;
        end
    end

    if sps.PowerguiInfo.SPID

        if DummyCircuit==0
            Model=[Model,' SPID'];
        end
        MUXU=0;
        SWC=0;
    end

    if sps.PowerguiInfo.Discrete&&~sps.PowerguiInfo.SPID&&sps.PowerguiInfo.Interpolate&&isequal('Tustin',sps.PowerguiInfo.SolverType)&&SWITCHES==1
        if sps.PowerguiInfo.ExternalGateDelay
            Model=[Model,' Interp_ext'];
        else

            Model=[Model,' Interp'];
        end
    end

    if~isempty(sps.Y.Q1Q4)
        THREELEVELBRIDGE=1;
    else
        THREELEVELBRIDGE=0;
    end


    NewModel=[sps.PowerguiInfo.BlockName,'/EquivalentModel',num2str(NetworkNumber)];



    CurrentEquivalentModel=find_system(sps.PowerguiInfo.BlockName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'lookundermasks','on','Regexp','on','Name','^EquivalentModel');
    if~isempty(CurrentEquivalentModel)&&NetworkNumber==1


        for i=1:length(CurrentEquivalentModel)
            delete_block(CurrentEquivalentModel{i});
        end
    end
    set_param(Model,'UserData',sps);
    add_block(Model,NewModel);



















    set_param(NewModel,'position',[15,70+50*(NetworkNumber-1),143,105+50*(NetworkNumber-1)]);



    if SWITCHES&&sps.PowerguiInfo.Phasor==0&&sps.PowerguiInfo.DiscretePhasor==0&&DummyCircuit==0
        CreateGotoStructure([NewModel,'/Status'],sps.Status.Tags,sps.Status.Demux);
    end



    if sps.PowerguiInfo.DiscretePhasor,WantDSS=1;end

    if WantDSS&&~sps.PowerguiInfo.DiscretePhasor
        if~isempty(sps.DSS.model.outTags)
            CreateGotoStructure([NewModel,'/DSS out'],sps.DSS.model.outTags,sps.DSS.model.outDemux);
        else

            CreateGotoStructure([NewModel,'/DSS out'],{[]},1);
        end
    end



    if SWITCHES&&DummyCircuit==0
        if sps.PowerguiInfo.Interpolate&&strcmp(sps.PowerguiInfo.SolverType,'Tustin')&&sps.PowerguiInfo.ExternalGateDelay
            CreateFromsSubsystem([NewModel,'/Gates'],sps.Gates.Tags,3*sps.Gates.Mux);
            totalSignals=sum(3*sps.Gates.Mux);
            set_param([NewModel,'/External Delays/Selector GATES'],'indices',mat2str(1:3:totalSignals),'InputPortWidth',num2str(totalSignals));
            set_param([NewModel,'/External Delays/Selector ON'],'indices',mat2str(2:3:totalSignals),'InputPortWidth',num2str(totalSignals));
            set_param([NewModel,'/External Delays/Selector OFF'],'indices',mat2str(3:3:totalSignals),'InputPortWidth',num2str(totalSignals));
        else
            CreateFromsSubsystem([NewModel,'/Gates'],sps.Gates.Tags,sps.Gates.Mux);
        end
    end


    if WantDSS
        CreateFromsSubsystem([NewModel,'/DSS in'],sps.DSS.model.inTags,sps.DSS.model.inMux);
    end



    if YOUT
        CreateGotoStructure([NewModel,'/Yout'],sps.Y.Tags,sps.Y.Demux);
        if DummyFromsGotos||DummyGotos
            set_param([NewModel,'/Yout/Constant'],'Value',mat2str(zeros(1,sum(sps.Y.Demux))));
        end


        if sps.PowerguiInfo.DiscretePhasor
            if~isempty(sps.DSS.block)
                if~isempty(sps.DSS.model.reorderout.indices)

                    set_param([NewModel,'/Yout/Reorder'],'indices',mat2str(sps.DSS.model.reorderout.indices),'InputPortWidth',mat2str(sps.DSS.model.reorderout.width));
                end
            end
        else
            if WantDSS
                if isempty(sps.DSS.model.reorderout.indices)

                    NbSignals=sum(sps.Y.Demux);
                    set_param([NewModel,'/Yout/Reorder'],'indices',mat2str(1:NbSignals),'InputPortWidth',mat2str(NbSignals));
                else

                    set_param([NewModel,'/Yout/Reorder'],'indices',mat2str(sps.DSS.model.reorderout.indices),'InputPortWidth',mat2str(sps.DSS.model.reorderout.width));
                end
            end
        end

    else

        if DummyCircuit==0
            addterms([NewModel,'/Yout']);
        end
    end


    if sps.PowerguiInfo.DiscretePhasor,FLUX=0;end
    if FLUX

        CreateFromsSubsystem([NewModel,'/Yout/Flux'],sps.Flux.Tags,sps.Flux.Mux);
    end
    if THREELEVELBRIDGE

        set_param([NewModel,'/Yout/Multimeter'],'N',mat2str(sps.Y.TotalNumberOfSignals));
        set_param([NewModel,'/Yout/Multimeter'],'Q1Q4',mat2str(sps.Y.Q1Q4));
        set_param([NewModel,'/Yout/Multimeter'],'D1D4',mat2str(sps.Y.D1D4));
        set_param([NewModel,'/Yout/Multimeter'],'Others',mat2str(sps.Y.Others));
    end




    if MUXU&&SWITCHES&&DummyCircuit==0
        Mux_u=mat2str([sps.SwitchDevices.qty,sum(sps.U.Mux)]);
        set_param([NewModel,'/Sources/Mux_u'],'inputs',Mux_u);
    end


    if SWC&&SWITCHES&&DummyCircuit==0
        N=num2str(sps.SwitchDevices.qty);
        if sps.PowerguiInfo.Phasor||sps.PowerguiInfo.DiscretePhasor
            set_param([NewModel,'/Sources/SwitchCurrents'],'Value',['complex(zeros(',N,',1),zeros(',N,',1))']);
        else
            set_param([NewModel,'/Sources/SwitchCurrents'],'Value',['zeros(',N,',1)']);
        end
    end


    if sps.PowerguiInfo.DiscretePhasor
        if~isempty(sps.DSS.block)
            if~isempty(sps.DSS.model.reordersrc.indices)

                set_param([NewModel,'/Sources/Reorder'],'indices',mat2str(sps.DSS.model.reordersrc.indices),'InputPortWidth',mat2str(sps.DSS.model.reordersrc.width));
            end
        end
    else
        if WantDSS
            if isempty(sps.DSS.model.reordersrc.indices)

                NbSignals=sum(sps.U.Mux)+sps.SwitchDevices.qty;
                set_param([NewModel,'/Sources/Reorder'],'indices',mat2str(1:NbSignals),'InputPortWidth',mat2str(NbSignals));
            else

                set_param([NewModel,'/Sources/Reorder'],'indices',mat2str(sps.DSS.model.reordersrc.indices),'InputPortWidth',mat2str(sps.DSS.model.reordersrc.width));
            end
        end
    end

    if HAVEINPUTS
        CreateFromsSubsystem([NewModel,'/Sources'],sps.U.Tags,sps.U.Mux);
    end


    if NetworkNumber==1&&isempty(sps.mesurexmeter)&&~isempty(sps.multimeters)&&DummyFromsGotos==0&&DummyGotos==0

        add_block('power_utile/LonelyMultimeters',[NewModel,'/LonelyMultimeters']);
        set_param([NewModel,'/LonelyMultimeters'],'position',[115,202,227,231]);
    end




    function CreateGotoStructure(Subsystem,Tags,Setting)

        MAXIMUM_OUTPUTS=200;
        if isempty(Setting)
            return
        end
        if length(Setting)==1
            Setting=1;
        end
        NUMBER_OF_TAGS=length(Tags);
        if NUMBER_OF_TAGS>MAXIMUM_OUTPUTS
            NUMBER_OF_SUBCOMPONENTS=ceil(NUMBER_OF_TAGS/MAXIMUM_OUTPUTS);

            for i=1:NUMBER_OF_SUBCOMPONENTS

                num=num2str(i);
                subdivision=[Subsystem,'/sub',num];
                add_block('power_utile/subdivision',subdivision)
                set_param(subdivision,'position',[325,21+45*(i-1),395,49+45*(i-1)])

                debut=1+(i-1)*MAXIMUM_OUTPUTS;
                fin=i*MAXIMUM_OUTPUTS;
                fin=min(fin,NUMBER_OF_TAGS);
                CreateGotoStructure(subdivision,Tags(debut:fin),Setting(debut:fin));

                DEMUXSETTING(i)=sum(Setting(debut:fin));%#ok hopefully there is no -1 in the list
            end


            set_param([Subsystem,'/Demux'],'outputs',mat2str(DEMUXSETTING));

            for i=1:NUMBER_OF_SUBCOMPONENTS
                num=num2str(i);
                add_line(Subsystem,['Demux/',num],['sub',num,'/1']);
            end
            return
        else
            set_param([Subsystem,'/Demux'],'outputs',mat2str(Setting));
        end
        for i=1:NUMBER_OF_TAGS
            num=num2str(i);
            if strcmp(Tags{i},'ThreeLevelBridgeCurrents')

                add_block('power_utile/ThreeLevel',[Subsystem,'/Multimeter'])
                set_param([Subsystem,'/Multimeter'],'position',[325,21+45*(i-1),395,49+45*(i-1)])
                add_line(Subsystem,['Demux/',num],'Multimeter/1');
            elseif~isempty(Tags{i})

                add_block('built-in/Goto',[Subsystem,'/Goto',num])
                set_param([Subsystem,'/Goto',num],'position',[325,21+45*(i-1),395,49+45*(i-1)],'GotoTag',Tags{i},'TagVisibility','global')
                add_line(Subsystem,['Demux/',num],['Goto',num,'/1']);
            else

                add_block('built-in/Terminator',[Subsystem,'/Goto',num])
                set_param([Subsystem,'/Goto',num],'position',[325,21+45*(i-1),395,49+45*(i-1)])
                add_line(Subsystem,['Demux/',num],['Goto',num,'/1']);
            end
        end

        function CreateFromsSubsystem(Subsystem,Tags,Setting)

            MAXIMUM_INPUTS=200;
            if isempty(Setting)
                return
            end
            if length(Setting)==1
                Setting=1;
            end
            NUMBER_OF_TAGS=length(Tags);
            if NUMBER_OF_TAGS>MAXIMUM_INPUTS
                NUMBER_OF_SUBCOMPONENTS=ceil(NUMBER_OF_TAGS/MAXIMUM_INPUTS);

                for i=1:NUMBER_OF_SUBCOMPONENTS
                    num=num2str(i);
                    subdivision=[Subsystem,'/src',num];
                    add_block('power_utile/sources',subdivision)
                    set_param(subdivision,'position',[15,21+45*(i-1),85,49+45*(i-1)])

                    debut=1+(i-1)*MAXIMUM_INPUTS;
                    fin=i*MAXIMUM_INPUTS;
                    fin=min(fin,NUMBER_OF_TAGS);
                    CreateFromsSubsystem(subdivision,Tags(debut:fin),Setting(debut:fin));

                    MUXSETTING(i)=sum(Setting(debut:fin));%#ok hopefully there is no -1 in the list
                end


                set_param([Subsystem,'/Mux'],'inputs',mat2str(MUXSETTING));

                for i=1:NUMBER_OF_SUBCOMPONENTS
                    num=num2str(i);
                    add_line(Subsystem,['src',num,'/1'],['Mux/',num]);
                end
                return
            else
                set_param([Subsystem,'/Mux'],'inputs',mat2str(Setting));
            end
            for i=1:NUMBER_OF_TAGS
                num=num2str(i);
                if~isempty(Tags{i})

                    add_block('built-in/From',[Subsystem,'/From',num])
                    set_param([Subsystem,'/From',num],'position',[15,21+45*(i-1),85,49+45*(i-1)],'GotoTag',Tags{i})
                else
                    add_block('built-in/Ground',[Subsystem,'/From',num])
                    set_param([Subsystem,'/From',num],'position',[15,21+45*(i-1),85,49+45*(i-1)])
                end
                add_line(Subsystem,['From',num,'/1'],['Mux/',num]);
            end