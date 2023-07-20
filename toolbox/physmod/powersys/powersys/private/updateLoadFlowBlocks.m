function updateLoadFlowBlocks(Type,LF,option)



    switch Type
    case 'PositiveSequence'
        LFblocks=[LF.bus.blocks];
        Parents=get_param(LFblocks,'Parent');
        Title='Load Flow Tool Apply button';
        Question{1}='The following Load Flow blocks are inside a library link:';
        Question{2}=' ';
        LL=0;
        if~iscell(Parents)
            Parents={Parents};
        end
        for i=1:length(Parents)
            if~isequal(Parents{i},LF.model)
                if isequal('resolved',get_param(Parents{i},'LinkStatus'))
                    LL=LL+1;
                    blk=getfullname(LFblocks(i));
                    blk=strrep(blk,newline,char(32));
                    Question{end+1}=['  ',blk];%#ok
                end
            end
        end
        Question{end+1}=' ';
        if LL==1
            Question{1}='The following Load Flow block is inside a library link:';
            Question{end+1}='Do you want to apply the load flow solution to this block ?';
        else
            Question{end+1}='Do you want to apply the Load Flow solution to these blocks ?';
        end
        Question{end+1}='(These changes can be changed, propagated, or viewed using the ''Library Link'' menu item )';
        Action=1;
        if LL
            Button=questdlg(Question,Title);
            switch Button
            case 'Yes'
                Action=1;
            case 'No'
                Action=0;
            otherwise
                return
            end
        end

        for i=1:length(LF.bus)
            if isfinite(LF.bus(i).handle)
                if BlockInLibraryLink(LF.bus(i).handle,Action)
                    continue
                end
                set_param(LF.bus(i).handle,'VLF',num2str(abs(LF.bus(i).Vbus),4))
                set_param(LF.bus(i).handle,'angleLF',num2str(angle(LF.bus(i).Vbus)*180/pi,4))
            end
        end

        for i=1:length(LF.asm.handle)

            if BlockInLibraryLink(LF.asm.handle{i},Action)
                continue
            end

            Vbase=LF.asm.vnom{i}/sqrt(3)*sqrt(2);

            switch LF.asm.Units{i}
            case 'SI'
                Ibase=Vbase/(LF.asm.vnom{i}^2/LF.asm.pnom{i});
            case 'pu'
                Ibase=1.0;
            end

            InitialConditions=sprintf('[%g %g %g %g %g %g %g %g]',...
            LF.asm.slip{i},...
            LF.asm.Theta{i},...
            abs(LF.asm.I{i})*Ibase,...
            abs(LF.asm.I{i})*Ibase,...
            abs(LF.asm.I{i})*Ibase,...
            angle(LF.asm.I{i})*180/pi,...
            angle(LF.asm.I{i})*180/pi-120,...
            angle(LF.asm.I{i})*180/pi+120);


            if all(isfinite([LF.asm.slip{i},LF.asm.Theta{i},LF.asm.I{i}]))

                set_param(LF.asm.handle{i},'InitialConditions',InitialConditions);
            end

            Ws_nom=2*pi*LF.asm.freq{i}/LF.asm.pole{i};

            switch LF.asm.MechLoad{i}

            case 'Torque Tm'

                Tnom=LF.asm.pnom{i}/Ws_nom;
                ValueToSet_pu=LF.asm.T{i};
                ValueToSet_SI=LF.asm.T{i}*Tnom;
                InputName='Tm';
                InputSign='N.m';

            case 'Speed w'

                ValueToSet_pu=1;
                ValueToSet_SI=ValueToSet_pu*Ws_nom;
                InputName='w';
                InputSign='rad/s';

            end

            switch LF.asm.MechLoad{i}
            case{'Torque Tm','Speed w'}

                if~isempty(LF.asm.Srcblk{i})
                    switch LF.asm.Units{i}
                    case 'SI'
                        if isfinite(ValueToSet_SI)
                            set_loadflow_parameter(LF.asm.Srcblk{i},LF.asm.Srcparam{i},ValueToSet_SI);
                        end
                    case 'pu'
                        if isfinite(ValueToSet_pu)
                            set_loadflow_parameter(LF.asm.Srcblk{i},LF.asm.Srcparam{i},ValueToSet_pu);
                        end
                    end
                else



                    cant_set_loadflow_parameter(LF.asm.handle{i},InputName,InputSign,ValueToSet_SI,ValueToSet_pu,LF.asm.Units{i},option);

                end
            end

        end


        for i=1:length(LF.sm.handle)

            if BlockInLibraryLink(LF.sm.handle{i},Action)
                continue
            end

            Vbase=LF.sm.vnom{i}/sqrt(3)*sqrt(2);
            Zbase=LF.sm.vnom{i}^2/LF.sm.pnom{i};

            switch LF.sm.Units{i}
            case{'SI fundamental parameters',1}
                Ibase=Vbase/Zbase;
                Vbasex=LF.sm.Vfn{i};
            case{'per unit standard parameters','per unit fundamental parameters',0}
                Ibase=1.0;
                Vbasex=1.0;
            end

            switch LF.sm.blockType{i}
            case 'SM'
                InitialConditions=sprintf('[%g %g %g %g %g %g %g %g %g]',...
                LF.sm.dw0{i},...
                LF.sm.th0deg{i},...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                angle(LF.sm.I{i})*180/pi,...
                angle(LF.sm.I{i})*180/pi-120,...
                angle(LF.sm.I{i})*180/pi+120,...
                LF.sm.Vf{i}*Vbasex);

            case 'SMsimple'
                InitialConditions=sprintf('[%g %g %g %g %g %g %g %g]',...
                LF.sm.dw0{i},...
                LF.sm.th0deg{i}+90,...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                angle(LF.sm.I{i})*180/pi,...
                angle(LF.sm.I{i})*180/pi-120,...
                angle(LF.sm.I{i})*180/pi+120);

            end

            if all(isfinite([LF.sm.dw0{i},LF.sm.th0deg{i},LF.sm.I{i},LF.sm.Vf{i}]))

                set_param(LF.sm.handle{i},'InitialConditions',InitialConditions);
            end


            switch LF.sm.MechLoad{i}

            case 'Mechanical power Pm'


                if~isempty(LF.sm.srcblkPm{i})

                    if strcmp(LF.sm.srcparamPm{i},'ini1')
                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                    elseif strcmp(LF.sm.srcparamPm{i},'ini2')
                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},[LF.sm.pmec{i}/LF.sm.pnom{i},LF.sm.th0deg{i}]);
                    elseif strcmp(LF.sm.srcparamPm{i},'Value')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i});
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end
                    elseif strcmp(LF.sm.srcparamPm{i},'Before')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i});
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end

                    elseif strcmp(LF.sm.srcparamPm{i},'po')



                        gate=getSPSmaskvalues(LF.sm.srcblkPm{i},{'gate'});
                        gmin=gate(1);
                        gmax=gate(2);
                        po=LF.sm.pmec{i}/LF.sm.pnom{i};
                        poact=po;
                        pomax=gmax/(gmax-gmin);
                        pomin=gmin/(gmax-gmin);

                        warn1=0;
                        if po>=pomax
                            po=pomax*0.999;
                            warn1=1;
                        end
                        if po<=pomin
                            po=pomin*1.001;
                            warn1=1;
                        end

                        if warn1
                            messageLF{1}=['The Load Flow tool limited the ''Initial mechanical power (pu)'' parameter of ',getfullname(LF.sm.srcblkPm{i}),' block to a value of ',num2str(po),' pu'];
                            messageLF{2}=['The actual initial ''p0'' value computed by the tool (',num2str(poact),' pu) is outside the specified gate opening limits given by:'];
                            messageLF{3}='   gmin/(gmax-gmin) < p0 < gmax/(gmax-gmin)';
                            messageLF{4}=['   ',pomin,' < p0 < ',pomax];

                            switch option
                            case 2
                                warndlg(messageLF,'Load Flow message');
                                warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                            case 1
                                warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                            case 0

                            end

                        end

                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},po);

                    else
                        switch get_param(LF.sm.srcblkPm{i},'MaskType')
                        case 'Diesel Engine & Governor'
                            DEG=LF.sm.srcblkPm{i};
                            Tlim=getSPSmaskvalues(DEG,{'Tlim'});
                            Tmin=Tlim(1);
                            Tmax=Tlim(2);
                            po=LF.sm.pmec{i}/LF.sm.pnom{i};
                            poact=po;
                            pomax=Tmax/(Tmax-Tmin);
                            pomin=Tmin/(Tmax-Tmin);
                            warn1=0;
                            if po>=pomax
                                po=pomax*0.999;
                                warn1=1;
                            end
                            if po<=pomin
                                po=pomin*1.001;
                                warn1=1;
                            end
                            if warn1
                                DEGname=strrep(getfullname(DEG),newline,' ');
                                messageLF{1}=['The Load Flow tool limited the "Initial value of mechanical power Pm0(pu)" parameter of "',DEGname,'" block to a value of ',num2str(po),' pu'];
                                messageLF{2}=' ';
                                messageLF{3}=['The actual initial Pm0 value computed by the tool is equal to: ',num2str(poact),' pu and is outside the specified torque limits given by:'];
                                messageLF{4}='   Tmin/(Tmax-Tmin) < p0 < Tmax/(Tmax-Tmin)';
                                messageLF{5}=['   ',pomin,' < Pm0 < ',pomax];
                                switch option
                                case 2
                                    warndlg(messageLF,'Load Flow message');
                                    warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                                case 1
                                    warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                                case 0

                                end

                            end


                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},po);

                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end
                    end

                else

                    cant_set_loadflow_parameter(LF.sm.handle{i},'Pm','Watts',LF.sm.pmec{i},LF.sm.pmec{i}/LF.sm.pnom{i},LF.sm.Units{i},option);
                end

            case 'Speed w'



                wsync=2*pi*LF.sm.freq{i}/LF.sm.pp{i};
                Speedpu=1-LF.sm.dw0{i};
                SpeedSI=Speedpu*wsync;

                if~isempty(LF.sm.srcblkPm{i})

                    if strcmp(LF.sm.srcparamPm{i},'Value')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},SpeedSI);
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},Speedpu);
                        end
                    else

                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},Speedpu);
                    end

                else

                    cant_set_loadflow_parameter(LF.sm.handle{i},'w','rad/s',SpeedSI,Speedpu,LF.sm.Units{i},option)
                end

            end

            switch LF.sm.MechLoad{i}
            case{'Mechanical power Pm','Speed w'}


                if~isempty(LF.sm.srcblkSHTG{i})
                    set_loadflow_parameter(LF.sm.srcblkSHTG{i},LF.sm.srcparamSHTG{i},LF.sm.prefpu{i});
                elseif strcmp('NotAbleToSet',LF.sm.srcparamSHTG{i})
                    cant_set_loadflow_parameter(LF.sm.srcblkPm{i},'Pref','',[],LF.sm.prefpu{i},1,option);
                end
            end


            Vf=abs(LF.sm.Vf{i});
            Vt0=abs(LF.sm.Vt{i});

            if~isempty(LF.sm.srcblkVref{i})

                if strcmp(LF.sm.srcparamVref{i},'v0')

                    set_loadflow_parameter(LF.sm.srcblkVref{i},LF.sm.srcparamVref{i},[Vt0,Vf]);

                    switch get_param(LF.sm.srcblkVref{i},'MaskType')
                    case 'ST2A Excitation System'
                        It0=abs(LF.sm.I{i});
                        set_loadflow_parameter(LF.sm.srcblkVref{i},'I0',It0)
                    end

                else
                    switch LF.sm.Units{i}
                    case{'SI fundamental parameters',1}
                        New_setting=Vf*Vbasex;
                    otherwise
                        New_setting=Vf;
                    end
                    set_loadflow_parameter(LF.sm.srcblkVref{i},LF.sm.srcparamVref{i},New_setting);
                end

            else


                cant_set_loadflow_parameter(LF.sm.handle{i},'Vf','V',Vf*Vbasex,Vf,LF.sm.Units{i},option)

            end


            if~isempty(LF.sm.srcblkExci{i})

                Vref=LF.bus(LF.sm.busNumber{i}).vref*LF.bus(LF.sm.busNumber{i}).vbase/LF.sm.vnom{i};
                set_loadflow_parameter(LF.sm.srcblkExci{i},LF.sm.srcparamExci{i},Vref);

            elseif strcmp('NotAbleToSet',LF.sm.srcblkExci{i})

                cant_set_loadflow_parameter(LF.sm.srcblkVref{i},'vref','',[],Vf,1,option)

            end

        end


        for i=1:length(LF.vsrc.handle)

            if BlockInLibraryLink(LF.vsrc.handle{i},Action)
                continue
            end

            if isfinite(LF.vsrc.Vint{i})
                Vpu=abs(LF.vsrc.Vint{i});
                Vangle=angle(LF.vsrc.Vint{i})*180/pi;
                Vbase=LF.bus(LF.vsrc.busNumber{i}).vbase;
                switch LF.vsrc.blockType{i}
                case 'Vsrc'
                    V=sprintf('(%g)*%g',Vbase,Vpu);
                    set_param(LF.vsrc.handle{i},'Voltage',V);
                    set_param(LF.vsrc.handle{i},'PhaseAngle',num2str(Vangle));
                case 'Vprog'
                    PositiveSequence=getSPSmaskvalues(LF.vsrc.handle{i},{'PositiveSequence'});
                    freq=PositiveSequence(3);
                    PSeq=sprintf('[(%g)*%g %g %g]',Vbase,Vpu,Vangle,freq);
                    set_param(LF.vsrc.handle{i},'PositiveSequence',PSeq);
                end
            end
        end


        for i=1:length(LF.pqload.handle)

            if BlockInLibraryLink(LF.pqload.handle{i},Action)
                continue
            end

            if isfinite(LF.pqload.S{i})
                PQ0=sprintf('[%g %g]',real(LF.pqload.S{i})*LF.Pbase,imag(LF.pqload.S{i})*LF.Pbase);
                set_param(LF.pqload.handle{i},'ActiveReactivePowers',PQ0);
            end

            if isfinite(LF.pqload.Vt{i})
                Vbase=LF.bus(LF.pqload.busNumber{i}).vbase;
                Vnom=LF.pqload.vnom{i};

                Vpu_vnom=abs(LF.pqload.Vt{i})*Vbase/Vnom;
                Vangle=angle(LF.pqload.Vt{i})*180/pi;

                V0=sprintf('[%g %g]',Vpu_vnom,Vangle);
                set_param(LF.pqload.handle{i},'PositiveSequence',V0);
            end

        end


        for i=1:length(LF.rlcload.handle)

            if BlockInLibraryLink(LF.rlcload.handle{i},Action)
                continue
            end

            if isfinite(LF.rlcload.Vt{i})
                Vpu=abs(LF.rlcload.Vt{i});
                Vbase=LF.bus(LF.rlcload.busNumber{i}).vbase;
                switch LF.rlcload.busType{i}
                case 'PQ'
                    if Vpu>0
                        V=sprintf('(%g)*%g',Vbase,Vpu);
                        set_param(LF.rlcload.handle{i},'NominalVoltage',V);
                    end
                case 'I'
                    if Vpu>0
                        V=sprintf('(%g)*%g',Vbase,sqrt(Vpu));
                        set_param(LF.rlcload.handle{i},'NominalVoltage',V);
                    end
                end
            end

        end
    case 'Unbalanced'






















































        a=exp(2i*pi/3);
        a2=a*a;



        for i=1:length(LF.bus)
            if isfinite(LF.bus(i).handle)



                switch LF.bus(i).NumberOfPhases
                case{1,2}
                    set_param(LF.bus(i).handle,'VLF','NaN')
                    set_param(LF.bus(i).handle,'angleLF','NaN')
                    set_param(LF.bus(i).handle,'VLFb','NaN')
                    set_param(LF.bus(i).handle,'angleLFb','NaN')
                    set_param(LF.bus(i).handle,'VLFc','NaN')
                    set_param(LF.bus(i).handle,'angleLFc','NaN')
                end



                switch LF.bus(i).ID(end)
                case 'a'
                    set_param(LF.bus(i).handle,'VLF',num2str(abs(LF.bus(i).Vbus),4))
                    set_param(LF.bus(i).handle,'angleLF',num2str(angle(LF.bus(i).Vbus)*180/pi,4))
                case 'b'
                    set_param(LF.bus(i).handle,'VLFb',num2str(abs(LF.bus(i).Vbus),4))
                    set_param(LF.bus(i).handle,'angleLFb',num2str(angle(LF.bus(i).Vbus)*180/pi,4))
                case 'c'
                    set_param(LF.bus(i).handle,'VLFc',num2str(abs(LF.bus(i).Vbus),4))
                    set_param(LF.bus(i).handle,'angleLFc',num2str(angle(LF.bus(i).Vbus)*180/pi,4))
                end
            end
        end


        for i=1:length(LF.asm.handle)





            Vbase=LF.asm.vnom{i}/sqrt(3)*sqrt(2);

            switch LF.asm.Units{i}
            case 'SI'
                Ibase=Vbase/(LF.asm.vnom{i}^2/LF.asm.pnom{i});
            case 'pu'
                Ibase=1.0;
            end

            InitialConditions=sprintf('[%g %g %g %g %g %g %g %g]',...
            LF.asm.slip{i},...
            LF.asm.Theta{i},...
            abs(LF.asm.I{i}(1))*Ibase,...
            abs(LF.asm.I{i}(2))*Ibase,...
            abs(LF.asm.I{i}(3))*Ibase,...
            angle(LF.asm.I{i}(1))*180/pi,...
            angle(LF.asm.I{i}(2))*180/pi,...
            angle(LF.asm.I{i}(3))*180/pi);


            if all(isfinite([LF.asm.slip{i},LF.asm.Theta{i},LF.asm.I{i}]))

                set_param(LF.asm.handle{i},'InitialConditions',InitialConditions);
            end

            Ws_nom=2*pi*LF.asm.freq{i}/LF.asm.pole{i};

            switch LF.asm.MechLoad{i}

            case 'Torque Tm'

                Tnom=LF.asm.pnom{i}/Ws_nom;
                ValueToSet_pu=LF.asm.T{i};
                ValueToSet_SI=LF.asm.T{i}*Tnom;
                InputName='Tm';
                InputSign='N.m';

            case 'Speed w'

                ValueToSet_pu=1;
                ValueToSet_SI=ValueToSet_pu*Ws_nom;
                InputName='w';
                InputSign='rad/s';

            end

            switch LF.asm.MechLoad{i}
            case{'Torque Tm','Speed w'}

                if~isempty(LF.asm.Srcblk{i})
                    switch LF.asm.Units{i}
                    case 'SI'
                        if isfinite(ValueToSet_SI)
                            set_loadflow_parameter(LF.asm.Srcblk{i},LF.asm.Srcparam{i},ValueToSet_SI);
                        end
                    case 'pu'
                        if isfinite(ValueToSet_pu)
                            set_loadflow_parameter(LF.asm.Srcblk{i},LF.asm.Srcparam{i},ValueToSet_pu);
                        end
                    end
                else



                    cant_set_loadflow_parameter(LF.asm.handle{i},InputName,InputSign,ValueToSet_SI,ValueToSet_pu,LF.asm.Units{i},option);

                end
            end

        end


        for i=1:length(LF.sm.handle)





            Vbase=LF.sm.vnom{i}/sqrt(3)*sqrt(2);
            Zbase=LF.sm.vnom{i}^2/LF.sm.pnom{i};

            switch LF.sm.Units{i}
            case{'SI fundamental parameters',1}
                Ibase=Vbase/Zbase;
                Vbasex=LF.sm.Vfn{i};
            case{'per unit standard parameters','per unit fundamental parameters',0}
                Ibase=1.0;
                Vbasex=1.0;
            end

            switch LF.sm.blockType{i}
            case 'SM'
                InitialConditions=sprintf('[%g %g %g %g %g %g %g %g %g]',...
                LF.sm.dw0{i},...
                LF.sm.th0deg{i},...
                abs(LF.sm.I{i}(1))*Ibase,...
                abs(LF.sm.I{i}(2))*Ibase,...
                abs(LF.sm.I{i}(3))*Ibase,...
                angle(LF.sm.I{i}(1))*180/pi,...
                angle(LF.sm.I{i}(2))*180/pi,...
                angle(LF.sm.I{i}(3))*180/pi,...
                LF.sm.Vf{i}*Vbasex);

            case 'SMsimple'
                InitialConditions=sprintf('[%g %g %g %g %g %g %g %g]',...
                LF.sm.dw0{i},...
                LF.sm.th0deg{i}+90,...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                abs(LF.sm.I{i})*Ibase,...
                angle(LF.sm.I{i})*180/pi,...
                angle(LF.sm.I{i})*180/pi-120,...
                angle(LF.sm.I{i})*180/pi+120);

            end

            if all(isfinite([LF.sm.dw0{i},LF.sm.th0deg{i},LF.sm.I{i},LF.sm.Vf{i}]))

                set_param(LF.sm.handle{i},'InitialConditions',InitialConditions);
            end


            switch LF.sm.MechLoad{i}

            case 'Mechanical power Pm'


                if~isempty(LF.sm.srcblkPm{i})

                    if strcmp(LF.sm.srcparamPm{i},'ini1')
                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                    elseif strcmp(LF.sm.srcparamPm{i},'ini2')
                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},[LF.sm.pmec{i}/LF.sm.pnom{i},LF.sm.th0deg{i}]);
                    elseif strcmp(LF.sm.srcparamPm{i},'Value')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i});
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end
                    elseif strcmp(LF.sm.srcparamPm{i},'Before')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i});
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end

                    elseif strcmp(LF.sm.srcparamPm{i},'po')



                        gate=getSPSmaskvalues(LF.sm.srcblkPm{i},{'gate'});
                        gmin=gate(1);
                        gmax=gate(2);
                        po=LF.sm.pmec{i}/LF.sm.pnom{i};
                        poact=po;
                        pomax=gmax/(gmax-gmin);
                        pomin=gmin/(gmax-gmin);

                        warn1=0;
                        if po>=pomax
                            po=pomax*0.999;
                            warn1=1;
                        end
                        if po<=pomin
                            po=pomin*1.001;
                            warn1=1;
                        end

                        if warn1
                            messageLF{1}=['The Load Flow tool limited the ''Initial mechanical power (pu)'' parameter of ',getfullname(LF.sm.srcblkPm{i}),' block to a value of ',num2str(po),' pu'];
                            messageLF{2}=['The actual initial ''p0'' value computed by the tool (',num2str(poact),' pu) is outside the specified gate opening limits given by:'];
                            messageLF{3}='   gmin/(gmax-gmin) < p0 < gmax/(gmax-gmin)';
                            messageLF{4}=['   ',pomin,' < p0 < ',pomax];

                            switch option
                            case 2
                                warndlg(messageLF,'Load Flow message');
                                warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                            case 1
                                warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                            case 0

                            end

                        end

                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},po);

                    else
                        switch get_param(LF.sm.srcblkPm{i},'MaskType')
                        case 'Diesel Engine & Governor'
                            DEG=LF.sm.srcblkPm{i};
                            Tlim=getSPSmaskvalues(DEG,{'Tlim'});
                            Tmin=Tlim(1);
                            Tmax=Tlim(2);
                            po=LF.sm.pmec{i}/LF.sm.pnom{i};
                            poact=po;
                            pomax=Tmax/(Tmax-Tmin);
                            pomin=Tmin/(Tmax-Tmin);
                            warn1=0;
                            if po>=pomax
                                po=pomax*0.999;
                                warn1=1;
                            end
                            if po<=pomin
                                po=pomin*1.001;
                                warn1=1;
                            end
                            if warn1
                                DEGname=strrep(getfullname(DEG),newline,' ');
                                messageLF{1}=['The Load Flow tool limited the "Initial value of mechanical power Pm0(pu)" parameter of "',DEGname,'" block to a value of ',num2str(po),' pu'];
                                messageLF{2}=' ';
                                messageLF{3}=['The actual initial Pm0 value computed by the tool is equal to: ',num2str(poact),' pu and is outside the specified torque limits given by:'];
                                messageLF{4}='   Tmin/(Tmax-Tmin) < p0 < Tmax/(Tmax-Tmin)';
                                messageLF{5}=['   ',pomin,' < Pm0 < ',pomax];
                                switch option
                                case 2
                                    warndlg(messageLF,'Load Flow message');
                                    warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                                case 1
                                    warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
                                case 0

                                end

                            end


                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},po);

                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},LF.sm.pmec{i}/LF.sm.pnom{i});
                        end
                    end

                else

                    cant_set_loadflow_parameter(LF.sm.handle{i},'Pm','Watts',LF.sm.pmec{i},LF.sm.pmec{i}/LF.sm.pnom{i},LF.sm.Units{i},option);
                end

            case 'Speed w'



                wsync=2*pi*LF.sm.freq{i}/LF.sm.pp{i};
                Speedpu=1-LF.sm.dw0{i};
                SpeedSI=Speedpu*wsync;

                if~isempty(LF.sm.srcblkPm{i})

                    if strcmp(LF.sm.srcparamPm{i},'Value')
                        switch LF.sm.Units{i}
                        case{'SI fundamental parameters',1}
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},SpeedSI);
                        otherwise
                            set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},Speedpu);
                        end
                    else

                        set_loadflow_parameter(LF.sm.srcblkPm{i},LF.sm.srcparamPm{i},Speedpu);
                    end

                else

                    cant_set_loadflow_parameter(LF.sm.handle{i},'w','rad/s',SpeedSI,Speedpu,LF.sm.Units{i},option)
                end

            end

            switch LF.sm.MechLoad{i}
            case{'Mechanical power Pm','Speed w'}


                if~isempty(LF.sm.srcblkSHTG{i})
                    set_loadflow_parameter(LF.sm.srcblkSHTG{i},LF.sm.srcparamSHTG{i},LF.sm.prefpu{i});
                elseif strcmp('NotAbleToSet',LF.sm.srcparamSHTG{i})
                    cant_set_loadflow_parameter(LF.sm.srcblkPm{i},'Pref','',[],LF.sm.prefpu{i},1,option);
                end
            end


            Vf=abs(LF.sm.Vf{i});

            Vt0=abs(sum(LF.sm.Vt{i}.*[1,a,a2])/3);

            if~isempty(LF.sm.srcblkVref{i})

                if strcmp(LF.sm.srcparamVref{i},'v0')

                    set_loadflow_parameter(LF.sm.srcblkVref{i},LF.sm.srcparamVref{i},[Vt0,Vf]);

                    switch get_param(LF.sm.srcblkVref{i},'MaskType')
                    case 'ST2A Excitation System'
                        It0=abs(LF.sm.I{i});
                        set_loadflow_parameter(LF.sm.srcblkVref{i},'I0',It0)
                    end

                else
                    switch LF.sm.Units{i}
                    case{'SI fundamental parameters',1}
                        New_setting=Vf*Vbasex;
                    otherwise
                        New_setting=Vf;
                    end
                    set_loadflow_parameter(LF.sm.srcblkVref{i},LF.sm.srcparamVref{i},New_setting);
                end

            else


                cant_set_loadflow_parameter(LF.sm.handle{i},'Vf','V',Vf*Vbasex,Vf,LF.sm.Units{i},option)

            end


            if~isempty(LF.sm.srcblkExci{i})

                Vref=LF.bus(LF.sm.busNumber{i}(1)).vref*LF.bus(LF.sm.busNumber{i}(1)).vbase*sqrt(3)/LF.sm.vnom{i};
                set_loadflow_parameter(LF.sm.srcblkExci{i},LF.sm.srcparamExci{i},Vref);

            elseif strcmp('NotAbleToSet',LF.sm.srcblkExci{i})

                cant_set_loadflow_parameter(LF.sm.srcblkVref{i},'vref','',[],Vf,1,option)

            end

        end


        for iBlock=1:length([LF.vsrc.handle])





            if isfinite(LF.vsrc.Vint{iBlock})
                Vpu=abs(LF.vsrc.Vint{iBlock});
                Vangle=angle(LF.vsrc.Vint{iBlock})*180/pi;
                Vbase=LF.bus(LF.vsrc.busNumber{iBlock}).vbase;
                if strcmp(LF.vsrc.blockType{iBlock},'Vsrc 1ph')&&length(LF.vsrc.busNumber{iBlock})==2
                    Vpu=abs(LF.vsrc.Vint{iBlock}(1)-LF.vsrc.Vint{iBlock}(2));
                    Vangle=angle(LF.vsrc.Vint{iBlock}(1)-LF.vsrc.Vint{iBlock}(2))*180/pi;
                end
                switch LF.vsrc.blockType{iBlock}
                case 'Vsrc'
                    VoltagePhases=get_param(LF.vsrc.handle{iBlock},'VoltagePhases');
                    if strcmp(VoltagePhases,'off')
                        Pref=str2double(get_param(LF.vsrc.handle{iBlock},'Pref'));
                        Qref=str2double(get_param(LF.vsrc.handle{iBlock},'Qref'));
                        set_param(LF.vsrc.handle{iBlock},'Prefabc',num2str([Pref/3,Pref/3,Pref/3],'[%g %g %g]'));
                        set_param(LF.vsrc.handle{iBlock},'Qrefabc',num2str([Qref/3,Qref/3,Qref/3],'[%g %g %g]'));
                    end

                    V=sprintf('[ %g %g %g]*%g',Vpu(1),Vpu(2),Vpu(3),Vbase);
                    set_param(LF.vsrc.handle{iBlock},'Voltage_phases',V);
                    A=sprintf('[ %g %g %g]',Vangle(1),Vangle(2),Vangle(3));
                    set_param(LF.vsrc.handle{iBlock},'PhaseAngles_phases',A);
                    set_param(LF.vsrc.handle{iBlock},'VoltagePhases','on');
                case 'Vsrc 1ph'

                    V=sprintf('%g*%g*sqrt(2)',Vpu,Vbase);
                    set_param(LF.vsrc.handle{iBlock},'Amplitude',V);
                    A=sprintf('%g',Vangle);
                    set_param(LF.vsrc.handle{iBlock},'Phase',A);

                case 'Vprog'

                    PositiveSequence=getSPSmaskvalues(LF.vsrc.handle{i},{'PositiveSequence'});
                    freq=PositiveSequence(3);
                    PSeq=sprintf('[(%g)*%g %g %g]',Vbase,Vpu,Vangle,freq);
                    set_param(LF.vsrc.handle{i},'PositiveSequence',PSeq);
                end
            end
        end


        for i=1:length(LF.pqload.handle)
            if~isfinite(LF.pqload.Vt{i})
                continue
            end
            Vpu_vnom=abs(LF.pqload.Vseq1{i});
            Vangle=angle(LF.pqload.Vseq1{i})*180/pi;
            V0=sprintf('[%g %g]',Vpu_vnom,Vangle);
            set_param(LF.pqload.handle{i},'PositiveSequence',V0);
        end


        for iBlock=1:length(LF.rlcload.handle)




            if strcmp(LF.rlcload.busType{iBlock},'Z'),continue;end
            if~isfinite(LF.rlcload.Vt{iBlock}),continue;end

            Vbase=LF.bus(LF.rlcload.busNumber{iBlock}).vbase;
            switch LF.rlcload.blockType{iBlock}
            case 'RLC load'
                connection=get_param(LF.rlcload.handle{iBlock},'Configuration');
                UnbalancedPower=get_param(LF.rlcload.handle{iBlock},'UnbalancedPower');
                if strcmp(UnbalancedPower,'off')

                    set_param(LF.rlcload.handle{iBlock},'UnbalancedPower','on');
                    P=str2double(get_param(LF.rlcload.handle{iBlock},'ActivePower'));
                    QL=str2double(get_param(LF.rlcload.handle{iBlock},'InductivePower'));
                    QC=str2double(get_param(LF.rlcload.handle{iBlock},'CapacitivePower'));
                    if strcmp(connection,'Delta')
                        set_param(LF.rlcload.handle{iBlock},'Pabcp',num2str([P/3,P/3,P/3],'[%g %g %g]'));
                        set_param(LF.rlcload.handle{iBlock},'QLabcp',num2str([QL/3,QL/3,QL/3],'[%g %g %g]'));
                        set_param(LF.rlcload.handle{iBlock},'QCabcp',num2str([QC/3,QC/3,QC/3],'[%g %g %g]'));
                    else
                        set_param(LF.rlcload.handle{iBlock},'Pabc',num2str([P/3,P/3,P/3],'[%g %g %g]'));
                        set_param(LF.rlcload.handle{iBlock},'QLabc',num2str([QL/3,QL/3,QL/3],'[%g %g %g]'));
                        set_param(LF.rlcload.handle{iBlock},'QCabc',num2str([QC/3,QC/3,QC/3],'[%g %g %g]'));
                    end
                end
                switch LF.rlcload.busType{iBlock}
                case 'PQ'
                    switch connection
                    case 'Y (grounded)'

                        Vpu=abs(LF.rlcload.Vt{iBlock});
                        V=sprintf('[ %g %g %g]*%g',Vpu(1),Vpu(2),Vpu(3),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabc',V);
                    case{'Y (floating)','Y (neutral)'}

                        ib=LF.rlcload.busNumber{iBlock}(1);
                        Vng=LF.bus(ib).Vng;
                        Vpu=abs(LF.rlcload.Vt{iBlock}-Vng);
                        V=sprintf('[ %g %g %g]*%g',Vpu(1),Vpu(2),Vpu(3),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabc',V);
                    case 'Delta'

                        VpuLL=abs([(LF.rlcload.Vt{iBlock}(1)-LF.rlcload.Vt{iBlock}(2)),...
                        (LF.rlcload.Vt{iBlock}(2)-LF.rlcload.Vt{iBlock}(3)),...
                        (LF.rlcload.Vt{iBlock}(3)-LF.rlcload.Vt{iBlock}(1))]);
                        V=sprintf('[ %g %g %g]*%g',VpuLL(1),VpuLL(2),VpuLL(3),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabcp',V);
                    end
                case 'I'
                    switch connection
                    case 'Y (grounded)'

                        Vpu=abs(LF.rlcload.Vt{iBlock});
                        V=sprintf('[ %g %g %g]*%g',sqrt(Vpu(1)),sqrt(Vpu(2)),sqrt(Vpu(3)),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabc',V);
                    case{'Y (floating)','Y (neutral)'}

                        ib=LF.rlcload.busNumber{iBlock}(1);
                        Vng=LF.bus(ib).Vng;
                        Vpu=abs(LF.rlcload.Vt{iBlock}-Vng);
                        V=sprintf('[ %g %g %g]*%g',sqrt(Vpu(1)),sqrt(Vpu(2)),sqrt(Vpu(3)),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabc',V);
                    case 'Delta'

                        VpuLL=abs([(LF.rlcload.Vt{iBlock}(1)-LF.rlcload.Vt{iBlock}(2)),...
                        (LF.rlcload.Vt{iBlock}(2)-LF.rlcload.Vt{iBlock}(3)),...
                        (LF.rlcload.Vt{iBlock}(3)-LF.rlcload.Vt{iBlock}(1))]);
                        VpuLL=sqrt(VpuLL*sqrt(3));
                        V=sprintf('[ %g %g %g]*%g',VpuLL(1),VpuLL(2),VpuLL(3),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'Vabcp',V);
                    end

                end
            case 'RLC load 1ph'
                connection=LF.rlcload.connection{iBlock};
                switch LF.rlcload.busType{iBlock}
                case 'PQ'
                    switch connection
                    case{'ag','bg','cg'}

                        Vpu=abs(LF.rlcload.Vt{iBlock});
                        V=sprintf('%g*%g',Vpu,Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    case{'an','bn','cn'}

                        ib=LF.rlcload.busNumber{iBlock}(1);
                        switch connection(1)
                        case 'a'
                            Vng=LF.bus(ib).Vng;
                        case 'b'
                            Vng=LF.bus(ib-1).Vng;
                        case 'c'
                            Vng=LF.bus(ib-2).Vng;
                        end

                        Vpu=abs(LF.rlcload.Vt{iBlock}-Vng);
                        V=sprintf('%g*%g',Vpu,Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    case{'ab','bc','ca'}

                        Vpu=abs(LF.rlcload.Vt{iBlock}(1)-LF.rlcload.Vt{iBlock}(2));
                        V=sprintf('%g*%g',Vpu,Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    end
                case 'I'
                    switch connection
                    case{'ag','bg','cg'}

                        Vpu=abs(LF.rlcload.Vt{iBlock});
                        V=sprintf('%g*%g',sqrt(Vpu),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    case{'an','bn','cn'}

                        ib=LF.rlcload.busNumber{iBlock}(1);
                        switch connection(1)
                        case 'a'
                            Vng=LF.bus(ib).Vng;
                        case 'b'
                            Vng=LF.bus(ib-1).Vng;
                        case 'c'
                            Vng=LF.bus(ib-2).Vng;
                        end

                        Vpu=abs(LF.rlcload.Vt{iBlock}-Vng);
                        V=sprintf('%g*%g',sqrt(Vpu),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    case{'ab','bc','ca'}

                        Vpu=abs(LF.rlcload.Vt{iBlock}(1)-LF.rlcload.Vt{iBlock}(2));
                        V=sprintf('%g*%g',sqrt(Vpu*sqrt(3)),Vbase);
                        set_param(LF.rlcload.handle{iBlock},'NominalVoltage',V);
                    end

                end
            end
        end
    end



    function set_loadflow_parameter(Block,Parametre,Valeur)



        if any(isnan(Valeur))
            return
        end

        set_param(Block,Parametre,mat2str(Valeur,5));


        function cant_set_loadflow_parameter(Block,Parametre,Units,ValueSI,ValuePU,SIpu,option)


            if isnan(ValueSI)||isnan(ValuePU)
                return
            end

            messageLF{1}=['The Load Flow tool cannot set automatically the initial condition of the signal connected to the ',Parametre,' input of the: '];
            messageLF{2}=' ';
            messageLF{3}=['''',strrep(getfullname(Block),newline,' '),''' block.'];
            messageLF{4}=' ';
            messageLF{5}='If applicable, set the initial condition for this signal to: ';
            messageLF{6}=' ';

            switch SIpu
            case{'SI',1,'SI fundamental parameters'}
                messageLF{7}=sprintf('%g %s',ValueSI,Units);
            otherwise
                messageLF{7}=sprintf('%g pu.',ValuePU);
            end

            switch option
            case 2
                warndlg(messageLF,'Load Flow message');
            case 1
                warning('SpecializedPowerSystems:LoadFlowWarning',cell2mat(messageLF));
            case 0

            end


            function Bypass=BlockInLibraryLink(block,Action)


                Bypass=false;

                Parent=get_param(block,'Parent');
                if~isequal(Parent,bdroot(Parent))
                    if isequal('resolved',get_param(Parent,'LinkStatus'))

                        switch Action
                        case 0

                            Bypass=true;
                        end
                    end
                end
