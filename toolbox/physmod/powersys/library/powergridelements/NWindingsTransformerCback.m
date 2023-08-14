function NWindingsTransformerCback(block,~,Option)





    if strcmp(bdroot(block),'powerlib')


        return
    end

    aMaskObj=Simulink.Mask.get(block);
    AdvancedTab=aMaskObj.getDialogControl('Advanced');
    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    SetSaturation=strcmp('on',get_param(block,'SetSaturation'));

    if PowerguiInfo.Continuous||PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor||~SetSaturation||(PowerguiInfo.Discrete&&SetSaturation&&PowerguiInfo.AutomaticDiscreteSolvers)
        AdvancedTab.Visible='off';
    else
        AdvancedTab.Visible='on';
    end

    switch Option

    case{'Callback','CallBack'}

        LeftWindings=getSPSmaskvalues(block,{'LeftWindings'});
        RightWindings=getSPSmaskvalues(block,{'RightWindings'});
        NumberOfTaps=getSPSmaskvalues(block,{'NumberOfTaps'});
        DesiredTappedWindings=get_param(block,'TappedWindings');

        switch DesiredTappedWindings

        case 'taps on upper left winding'

            DesiredNumberOfTapsLeft=max(1,NumberOfTaps);
            DesiredNumberOfTapsRight=0;

        case 'taps on upper right winding'

            DesiredNumberOfTapsRight=max(1,NumberOfTaps);
            DesiredNumberOfTapsLeft=0;

        otherwise

            DesiredNumberOfTapsRight=0;
            DesiredNumberOfTapsLeft=0;

        end


        [CurrentNames,CurrentLeftTaps,CurrentRightTaps]=GetCurrentNames(block);

        DeltaLeftTaps=DesiredNumberOfTapsLeft-CurrentLeftTaps;
        DeltaRightTaps=DesiredNumberOfTapsRight-CurrentRightTaps;
        RequiredLeftPorts=max([2,2*LeftWindings])+DesiredNumberOfTapsLeft;
        RequiredRightPorts=max([2,2*RightWindings])+DesiredNumberOfTapsRight;



        if DeltaLeftTaps<0

            PortOffset=1;
            NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
            for i=CurrentLeftTaps:-1:DesiredNumberOfTapsLeft+1
                LineToDelete=get_param(NWTPortHandles.LConn(i+PortOffset),'line');
                delete_line(LineToDelete);
                delete_block(CurrentNames{i+PortOffset});
            end

            LConnTagsOld=get_param([block,'/NWindingsTransformer'],'LConnTags');
            LConnTagsAdd={};
            for i=1:DesiredNumberOfTapsLeft;
                LConnTagsAdd{i}=['1.',num2str(i)];%#ok mlint
            end
            suite=1+CurrentLeftTaps+1;
            LConnTags=[LConnTagsOld{1},LConnTagsAdd,LConnTagsOld{suite:end}];
            set_param([block,'/NWindingsTransformer'],'LConnTags',LConnTags);
        end




        if DeltaLeftTaps>0

            LConnTagsOld=get_param([block,'/NWindingsTransformer'],'LConnTags');
            for i=1:DesiredNumberOfTapsLeft;
                LConnTagsAdd{i}=['1.',num2str(i)];%#ok mlint
            end
            suite=1+CurrentLeftTaps+1;
            LConnTags=[LConnTagsOld{1},LConnTagsAdd,LConnTagsOld{suite:end}];
            set_param([block,'/NWindingsTransformer'],'LConnTags',LConnTags);

            PortOffset=1;
            NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
            for i=CurrentLeftTaps+1:DesiredNumberOfTapsLeft
                BlockName=[block,'/1.',num2str(i)];
                add_block('built-in/PMIOPort',BlockName);
                set_param(BlockName,'Position',[55,143+(i-4)*40,85,157+(i-4)*40],'orientation','right');
                set_param(BlockName,'port',num2str(i+PortOffset));
                set_param(BlockName,'side','Left');
                xPortHandle=get_param(BlockName,'PortHandles');
                add_line(block,NWTPortHandles.LConn(i+PortOffset),xPortHandle.RConn);
            end
        end



        CurrentNames=GetCurrentNames(block);
        NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
        NumberOfLeftPorts=length(NWTPortHandles.LConn);
        DeltaLeft=RequiredLeftPorts-NumberOfLeftPorts;



        if DeltaLeft<0

            for i=NumberOfLeftPorts:-1:RequiredLeftPorts+1
                LineToDelete=get_param(NWTPortHandles.LConn(i),'line');
                delete_line(LineToDelete);
                delete_block(CurrentNames{i});
            end

            LConnTagsOld=get_param([block,'/NWindingsTransformer'],'LConnTags');
            LConnTagsNew={};
            for i=1:NumberOfLeftPorts-abs(DeltaLeft);
                LConnTagsNew(i)=LConnTagsOld(i);
            end
            set_param([block,'/NWindingsTransformer'],'LConnTags',LConnTagsNew);
        end



        if DeltaLeft>0

            LConnTags=get_param([block,'/NWindingsTransformer'],'LConnTags');
            for i=length(LConnTags)+1:length(LConnTags)+DeltaLeft;
                LConnTags{i}=num2str(i);
            end
            set_param([block,'/NWindingsTransformer'],'LConnTags',LConnTags);
            NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');

            for i=NumberOfLeftPorts+1:RequiredLeftPorts
                BlockName=[block,'/NL',num2str(i)];
                add_block('built-in/PMIOPort',BlockName);
                set_param(BlockName,'Position',[55,143+(i-4)*40,85,157+(i-4)*40],'orientation','right')
                set_param(BlockName,'port',num2str(i));
                set_param(BlockName,'side','Left');
                xPortHandle=get_param(BlockName,'PortHandles');
                add_line(block,NWTPortHandles.LConn(i),xPortHandle.RConn);
            end
        end



        [CurrentNames]=GetCurrentNames(block);
        NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
        NumberOfLeftPorts=length(NWTPortHandles.LConn);



        if DeltaRightTaps<0

            PortOffset=1+NumberOfLeftPorts;
            for i=CurrentRightTaps:-1:DesiredNumberOfTapsRight+1
                LineToDelete=get_param(NWTPortHandles.RConn(i+1),'line');
                delete_line(LineToDelete);
                delete_block(CurrentNames{i+PortOffset});
            end

            RConnTagsOld=get_param([block,'/NWindingsTransformer'],'RConnTags');
            RConnTagsAdd={};
            for i=1:DesiredNumberOfTapsRight;
                RConnTagsAdd{i}=['1.',num2str(i)];%#ok mlint
            end
            suite=1+CurrentRightTaps+1;
            RConnTags=[RConnTagsOld{1},RConnTagsAdd,RConnTagsOld{suite:end}];
            set_param([block,'/NWindingsTransformer'],'RConnTags',RConnTags);
        end



        if DeltaRightTaps>0

            RConnTagsOld=get_param([block,'/NWindingsTransformer'],'RConnTags');
            for i=1:DesiredNumberOfTapsRight;
                RConnTagsAdd{i}=['1.',num2str(i)];%#ok mlint
            end
            suite=1+CurrentRightTaps+1;
            RConnTags=[RConnTagsOld{1},RConnTagsAdd,RConnTagsOld{suite:end}];
            set_param([block,'/NWindingsTransformer'],'RConnTags',RConnTags);
            PortOffset=1+NumberOfLeftPorts;
            NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');

            for i=CurrentRightTaps+1:DesiredNumberOfTapsRight
                FirstRightWinding=LeftWindings+1;
                BlockName=[block,'/',num2str(FirstRightWinding),'.',num2str(i)];
                add_block('built-in/PMIOPort',BlockName);
                set_param(BlockName,'Position',[255,143+(i-4)*40,285,157+(i-4)*40],'orientation','left');
                set_param(BlockName,'port',num2str(i+PortOffset));
                set_param(BlockName,'side','Right');
                xPortHandle=get_param(BlockName,'PortHandles');
                add_line(block,NWTPortHandles.RConn(i+1),xPortHandle.RConn);
            end
        end



        CurrentNames=GetCurrentNames(block);
        NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
        NumberOfRightPorts=length(NWTPortHandles.RConn);
        DeltaRight=RequiredRightPorts-NumberOfRightPorts;



        if DeltaRight<0

            for i=NumberOfRightPorts:-1:RequiredRightPorts+1
                LineToDelete=get_param(NWTPortHandles.RConn(i),'line');
                delete_line(LineToDelete);
                delete_block(CurrentNames{i+RequiredLeftPorts});
            end

            RConnTagsOld=get_param([block,'/NWindingsTransformer'],'RConnTags');
            RConnTagsNew={};
            for i=1:NumberOfRightPorts-abs(DeltaRight);
                RConnTagsNew(i)=RConnTagsOld(i);
            end
            set_param([block,'/NWindingsTransformer'],'RConnTags',RConnTagsNew);
        end



        if DeltaRight>0

            RConnTags=get_param([block,'/NWindingsTransformer'],'RConnTags');
            for i=length(RConnTags)+1:length(RConnTags)+DeltaRight;
                RConnTags{i}=num2str(i);
            end
            set_param([block,'/NWindingsTransformer'],'RConnTags',RConnTags);

            NWTPortHandles=get_param([block,'/NWindingsTransformer'],'PortHandles');
            for i=NumberOfRightPorts+1:RequiredRightPorts
                BlockName=[block,'/NR',num2str(i)];
                add_block('built-in/PMIOPort',BlockName);
                set_param(BlockName,'Position',[255,143+(i-4)*40,285,157+(i-4)*40],'orientation','left');
                set_param(BlockName,'port',num2str(i+RequiredLeftPorts),'side','Right');
                set_param(BlockName,'side','Right');
                xPortHandle=get_param(BlockName,'PortHandles');
                add_line(block,NWTPortHandles.RConn(i),xPortHandle.RConn);
            end
        end


        if DeltaRight~=0||DeltaLeft~=0||DeltaRightTaps~=0||DeltaLeftTaps~=0
            DesiredNumberOfTaps=DesiredNumberOfTapsRight+DesiredNumberOfTapsLeft;
            NewPortNames(block,DesiredTappedWindings,DesiredNumberOfTaps,LeftWindings,RightWindings);
        end

    case{'specify initial flux','SetSaturation','BAL','Hysteresis'}
        Parameters=Simulink.Mask.get(block).Parameters;
        Lm=strcmp(get_param(block,'MaskNames'),'Lm')==1;
        Saturation=strcmp(get_param(block,'MaskNames'),'Saturation')==1;
        NumberOfTaps=strcmp(get_param(block,'MaskNames'),'NumberOfTaps')==1;
        Hysteresis=strcmp(get_param(block,'MaskNames'),'Hysteresis')==1;
        DataFile=strcmp(get_param(block,'MaskNames'),'DataFile')==1;
        SpecifyInitialFlux=strcmp(get_param(block,'MaskNames'),'SpecifyInitialFlux')==1;
        InitialFlux=strcmp(get_param(block,'MaskNames'),'InitialFlux')==1;
        DiscreteSolver=strcmp(get_param(block,'MaskNames'),'DiscreteSolver')==1;
        switch get_param(block,'TappedWindings')
        case{'taps on upper left winding','taps on upper right winding'}
            Parameters(NumberOfTaps).Visible='on';
        otherwise
            Parameters(NumberOfTaps).Visible='off';
        end
        if SetSaturation
            Parameters(Hysteresis).Visible='on';
            if strcmp('on',get_param(block,'Hysteresis'))
                Parameters(DataFile).Visible='on';
            else
                Parameters(DataFile).Visible='off';
            end
            Parameters(Lm).Enabled='off';
            Parameters(Saturation).Enabled='on';
            Parameters(SpecifyInitialFlux).Visible='on';
            if strcmp(get_param(block,'SpecifyInitialFlux'),'on')
                Parameters(InitialFlux).Visible='on';
            else
                Parameters(InitialFlux).Visible='off';
            end
        else
            Parameters(Hysteresis).Visible='off';
            Parameters(DataFile).Visible='off';
            Parameters(Lm).Enabled='on';
            Parameters(Saturation).Enabled='off';
            Parameters(SpecifyInitialFlux).Visible='off';
            Parameters(InitialFlux).Visible='off';
        end
        if strcmp(get_param(block,'BreakLoop'),'on')
            Parameters(DiscreteSolver).Visible='off';
        else
            Parameters(DiscreteSolver).Visible='on';
        end

    case 'selected units'

        WantSIunits=strcmp('SI',get_param(block,'UNITS'));
        WantPUunits=~WantSIunits;
        HaveSIunits=strcmp('on',get_param(block,'DataType'));
        HavePUunits=~HaveSIunits;


        if(WantSIunits&&HavePUunits)||(WantPUunits&&HaveSIunits)

            NominalParameters=getSPSmaskvalues(block,{'NominalPower'},0,1);
            NominalVoltages=getSPSmaskvalues(block,{'NominalVoltages'},0,1);
            WindingResistances=getSPSmaskvalues(block,{'WindingResistances'},0,1);
            WindingInductances=getSPSmaskvalues(block,{'WindingInductances'},0,1);
            Rm=getSPSmaskvalues(block,{'Rm'},0,1);
            Lm=getSPSmaskvalues(block,{'Lm'},0,1);
            Saturation=getSPSmaskvalues(block,{'Saturation'},0,1);
            InitialFlux=getSPSmaskvalues(block,{'InitialFlux'},0,1);


            Pnom=NominalParameters(1);
            freq=NominalParameters(2);


            Rbase=NominalVoltages.^2./Pnom;
            Lbase=NominalVoltages.^2./Pnom./(2*pi*freq);
            Rmbase=Rbase(1);
            Lmbase=Lbase(1);
            BaseFlux=(NominalVoltages(1)/(2*pi*freq))*sqrt(2);
            BaseCurrent=(Pnom/NominalVoltages(1))*sqrt(2);

        end


        if(WantSIunits&&HavePUunits)


            WindingResistances=WindingResistances.*Rbase;
            WindingInductances=WindingInductances.*Lbase;
            Rm=Rm*Rmbase;
            Lm=Lm*Lmbase;
            Saturation=[Saturation(:,1)*BaseCurrent,Saturation(:,2)*BaseFlux];

            set_param(block,'DataType','on');
            set_param(block,'WindingResistances',mat2str(WindingResistances,5));
            set_param(block,'WindingInductances',mat2str(WindingInductances,5));
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'Lm',mat2str(Lm,5));
            set_param(block,'Saturation',mat2str(Saturation,5));
            if SetSaturation&&strcmp(get_param(block,'SpecifyInitialFlux'),'on')

                set_param(block,'InitialFlux',mat2str(InitialFlux*BaseFlux,5));
            end

            MaskPrompts=get_param(block,'MaskPrompts');
            MaskPrompts{12}='Winding resistances [R1 R2 ... Rn] (Ohm): ';
            MaskPrompts{13}='Winding leakage inductances [L1 L2 ... Ln] (H): ';
            MaskPrompts{14}='Magnetization resistance  Rm (Ohm)';
            MaskPrompts{15}='Magnetization inductance Lm (H)';
            MaskPrompts{16}='Saturation characteristic [ i1(A) ,  phi1(V.s) ;  i2 , phi2 ; ... ]';
            MaskPrompts{18}='Initial flux phi0 (V.s)';
            set_param(block,'MaskPrompts',MaskPrompts);

        elseif(WantPUunits&&HaveSIunits)


            WindingResistances=WindingResistances./Rbase;
            WindingInductances=WindingInductances./Lbase;
            Rm=Rm/Rmbase;
            Lm=Lm/Lmbase;
            Saturation=[Saturation(:,1)/BaseCurrent,Saturation(:,2)/BaseFlux];

            set_param(block,'DataType','off');
            set_param(block,'WindingResistances',mat2str(WindingResistances,5));
            set_param(block,'WindingInductances',mat2str(WindingInductances,5));
            set_param(block,'Rm',mat2str(Rm,5));
            set_param(block,'Lm',mat2str(Lm,5));
            set_param(block,'Saturation',mat2str(Saturation,5));

            if SetSaturation&&strcmp(get_param(block,'SpecifyInitialFlux'),'on')

                set_param(block,'InitialFlux',mat2str(InitialFlux/BaseFlux,5));
            end

            MaskPrompts=get_param(block,'MaskPrompts');
            MaskPrompts{12}='Winding resistances [R1 R2 ... Rn] (pu): ';
            MaskPrompts{13}='Winding leakage inductances [L1 L2 ... Ln] (pu): ';
            MaskPrompts{14}='Magnetization resistance  Rm (pu)';
            MaskPrompts{15}='Magnetization inductance Lm (pu)';
            MaskPrompts{16}='Saturation characteristic (pu) [ i1 ,  phi1 ;  i2 , phi2 ; ... ]';
            MaskPrompts{18}='Initial flux phi0 (pu)';
            set_param(block,'MaskPrompts',MaskPrompts);

        end

    end



    function NewPortNames(block,DesiredTappedWindings,DesiredNumberOfTaps,LeftWindings,RightWindings)


        CurrentNames=GetCurrentNames(block);
        for i=1:length(CurrentNames)
            set_param(CurrentNames{i},'Name',['x',num2str(i)])
        end

        switch DesiredTappedWindings

        case 'taps on upper left winding'

            NewNames{1}='1+';
            for i=1:DesiredNumberOfTaps
                NewNames{end+1}=['1.',num2str(i)];%#ok
            end
            NewNames{end+1}='1';
            for i=2:LeftWindings
                NewNames{end+1}=[num2str(i),'+'];%#ok
                NewNames{end+1}=num2str(i);%#ok
            end
            offset=LeftWindings;
            for i=1:RightWindings
                NewNames{end+1}=['+',num2str(offset+i)];%#ok
                NewNames{end+1}=num2str(offset+i);%#ok
            end

        case 'taps on upper right winding'

            NewNames={};
            for i=1:LeftWindings
                NewNames{end+1}=[num2str(i),'+'];%#ok
                NewNames{end+1}=num2str(i);%#ok
            end
            offset=LeftWindings;
            NewNames{end+1}=['+',num2str(offset+1)];
            for i=1:DesiredNumberOfTaps
                NewNames{end+1}=[num2str(offset+1),'.',num2str(i)];%#ok
            end
            NewNames{end+1}=num2str(offset+1);
            for i=2:RightWindings
                NewNames{end+1}=['+',num2str(offset+i)];%#ok
                NewNames{end+1}=num2str(offset+i);%#ok
            end

        otherwise

            NewNames={};
            for i=1:LeftWindings
                NewNames{end+1}=[num2str(i),'+'];%#ok
                NewNames{end+1}=num2str(i);%#ok
            end
            offset=LeftWindings;
            for i=1:RightWindings
                NewNames{end+1}=['+',num2str(i+offset)];%#ok
                NewNames{end+1}=num2str(i+offset);%#ok
            end

        end

        CurrentNames=GetCurrentNames(block);
        for i=length(NewNames):-1:1
            set_param(CurrentNames{i},'Name',NewNames{i})
        end




        function[CurrentNames,CurrentLeftTaps,CurrentRightTaps]=GetCurrentNames(block)



            CurrentNames=find_system(block,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Lookundermasks','on','followlinks','on','blocktype','PMIOPort');
            [d,sp]=sort(str2double(get_param(CurrentNames,'Port')));


            CurrentNames=CurrentNames(sp);

            Names=get_param(CurrentNames,'Name');

            CurrentLeftTaps=0;
            CurrentRightTaps=0;

            Tapside=2;
            for i=1:length(sp)
                if strfind(Names{i},'.')

                    if i==2
                        Tapside=1;
                    end
                    if Tapside==1
                        CurrentLeftTaps=CurrentLeftTaps+1;
                    else
                        CurrentRightTaps=CurrentRightTaps+1;
                    end
                end
            end