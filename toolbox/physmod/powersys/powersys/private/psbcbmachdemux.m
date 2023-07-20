function[]=psbcbmachdemux(object)






    sys=bdroot(object);
    if strcmp('running',get_param(sys,'SimulationStatus'))
        return
    end

    if strcmp(sys,'powerlib')|strcmp(sys,'powerlib2'),return;end

    type=get_param(object,'machType');
    CheckedMeasurements=[strcmp(get_param(object,'MaskValues'),'on')]';
    CurrentOutputs=getCurrentOutputs(object);

    switch type
    case 'Simplified synchronous'

        Simplified='on,on,on,on,on,on,';
        Synchronous='off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,';
        Asynchronous='off,off,off,off,off,off,off,off,off,off,off,';
        PermanentMag='off,off,off,off,off,off,off,';

        tag='SSM';
        names={'is_abc','vs_abc','e_abc','thetam','wm','Pe'};
        demuxString='[3 3 3 1 1 1  , 1 1 1 1 1 1 1 1 1 1]';
        paddingString='[0 0 0 0 0 0 0 0 0 0]';
        updateMask(object,tag,names,demuxString,CurrentOutputs(1:6),CheckedMeasurements(2:7),paddingString)

    case 'Synchronous'

        Simplified='off,off,off,off,off,off,';
        Synchronous='on,on,on,on,on,on,on,on,on,on,on,on,on,on,on,';
        Asynchronous='off,off,off,off,off,off,off,off,off,off,off,';
        PermanentMag='off,off,off,off,off,off,off,';

        tag='SM';
        names={'is_abc','is_qd','ifd','ik_qd','phim_qd','vs_qd','d_theta','wm','Pe','dw','theta','Te','Delta','Peo','Qeo'};
        demuxString='[3 2 1 3 2 2 1 1 1 1 1 1 1 1 1,  1]';
        paddingString='0';
        updateMask(object,tag,names,demuxString,CurrentOutputs(1:15),CheckedMeasurements(8:22),paddingString)

    case 'Asynchronous'

        Simplified='off,off,off,off,off,off,';
        Synchronous='off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,';
        Asynchronous='on,on,on,on,on,on,on,on,on,on,on,';
        PermanentMag='off,off,off,off,off,off,off,';

        tag='ASM';
        names={'ir_abc','ir_qd','phir_qd','vr_qd','is_abc','is_qd','phis_qd','vs_qd','wm','Te','thetam'};
        demuxString='[3 2 2 2 3 2 2 2 1 1 1  , 1 1 1 1 1]';
        paddingString='[0 0 0 0 0]';
        updateMask(object,tag,names,demuxString,CurrentOutputs(1:11),CheckedMeasurements(23:33),paddingString)

    case 'Permanent magnet synchronous'

        Simplified='off,off,off,off,off,off,';
        Synchronous='off,off,off,off,off,off,off,off,off,off,off,off,off,off,off,';
        Asynchronous='off,off,off,off,off,off,off,off,off,off,off,';
        PermanentMag='on,on,on,on,on,on,on,';

        tag='PMSM';
        names={'is_abc','is_qd','vs_qd','Hall effect','wm','thetam','Te'};
        demuxString='[3 2 2 3 1 1 1 , 1 1 1 1 1 1 1 1 1]';
        paddingString='[0 0 0 0 0 0 0 0 0]';
        updateMask(object,tag,names,demuxString,CurrentOutputs(1:7),CheckedMeasurements(34:40),paddingString)

    end

    MaskVisible=['on,',Simplified,Synchronous,Asynchronous,PermanentMag,'off'];
    set_param(object,'MaskVisibilityString',MaskVisible)


    function[]=updateMask(object,tag,names,demuxString,CurrentOutputs,CheckedMeasurements,paddingString)

        qtyPorts=length(names);


        for k=1:15
            tagName=['port',num2str(k)];


            h=find_system(object,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','all','tag',tagName);
            oldNames{k}=get_param(h,'Name');
        end


        for k=qtyPorts+1:15
            oldName=[object,'/',oldNames{k}];
            replace_block(oldName,'FollowLinks','on','Terminator','noprompt');
            set_param(oldName,'tag',['port',num2str(k)]);
            newStatus(k)=0;
        end


        for k=1:15
            newName=[tag,num2str(k)];
            set_param([object,'/',oldNames{k}],'Name',newName);
            set_param([object,'/',newName],'tag',['port',num2str(k)]);
            oldNames{k}=newName;
        end


        for k=1:qtyPorts
            newName=names{k};
            set_param([object,'/',oldNames{k}],'Name',newName);
            oldNames{k}=newName;
            newStatus(k)=CheckedMeasurements(k);
        end


        ToBeUpdated=find(xor(CurrentOutputs,CheckedMeasurements));
        for k=1:length(ToBeUpdated)
            tagName=['port',num2str(ToBeUpdated(k))];
            oldBlock=[object,'/',oldNames{ToBeUpdated(k)}];
            if CurrentOutputs(ToBeUpdated(k))==1
                replace_block(oldBlock,'FollowLinks','on','Terminator','noprompt');
                set_param(oldBlock,'tag',tagName);
            else
                replace_block(oldBlock,'FollowLinks','on','Outport','noprompt');
                set_param(oldBlock,'tag',tagName);
                portNumber=num2str(length(find(newStatus(1:ToBeUpdated(k)-1)))+1);
                set_param([object,'/',names{ToBeUpdated(k)}],'Port',portNumber);
            end
        end

        set_param([object,'/lastStatus'],'Value',['[ ',num2str(newStatus),' ]']);
        set_param([object,'/Demux'],'Outputs',demuxString);
        set_param([object,'/padding'],'Value',paddingString);





        function CurrentOutputs=getCurrentOutputs(object);


            for k=1:15
                tagName=['port',num2str(k)];


                h=find_system(object,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','FollowLinks','on','LookUnderMasks','all','tag',tagName);
                CurrentOutputs(k)=strcmp(get_param(h,'BlockType'),'Outport');
            end


            function SetMaskPrompts(object,units);

                switch units
                case 'pu'
                    MaskPrompts={...
'Machine type:'
'Machine units:'
'Line currents          [ isa  isb  isc ]'
'Terminal voltages   [ va  vb  vc ]'
'Internal voltages     [ ea  eb  ec ]'
'Rotor angle            [ thetam ]   rad'
'Rotor speed           [ wm ]'
'Electrical power     [ Pe ]'
'Stator currents                  [ isa  isb  isc ]'
'Stator currents                  [ iq  id ]'
'Field current                      [ ifd ]'
'Damper winding currents   [ ikq1  ikq2  ikd ]'
'Mutual fluxes                     [ phim_q   phim_d ]'
'Stator voltages                  [ vs_q   vs_d ]'
'Rotor angle deviation        [ d_theta ]   rad'
'Rotor speed                       [ wm ]'
'Electrical power                 [ Pe ]'
'Rotor speed deviation       [ dw ]'
'Rotor mechanical angle     [ theta ]   deg'
'Electromagnetic torque     [ Te ]'
'Load angle                         [ Delta ]   deg'
'Output active power          [ Peo ]'
'Output reactive power       [ Qeo ]'
'Rotor currents    [ ira  irb  irc ]'
'Rotor currents    [ ir_q   ir_d  ]'
'Rotor fluxes       [ phir_q   phir_d ]'
'Rotor voltages   [ vr_q   vr_d ]'
'Stator currents   [ ia  ib  ic ]'
'Stator currents   [ is_q   is_d ]'
'Stator fluxes      [ phis_q  phis_d ]'
'Stator voltages   [ vs_q  vs_d ]'
'Rotor speed       [ wm ]'
'Electromagnetic torque  [Te ]  pu'
'Rotor angle        [ thetam ]  rad'
'Stator currents   [ ia, ib, ic ]  A'
'stator currents    [ is_q   is_d ]  A'
'Stator voltages   [ vs_q   vs_d ]   V'
'Hall effect       [ h_a  h_b  h_c ]'
'Rotor speed       [ wm ]   rad/s'
'Rotor angle        [ thetam ]  rad'
'Electromagnetic torque  [Te ]  N.m'
'lastType:'
                    };
                case 'SI'
                    MaskPrompts={...
'Machine type:'
'Machine units:'
'Line currents          [ isa  isb  isc ]  A'
'Terminal voltages   [ va  vb  vc ]  V'
'Internal voltages     [ ea  eb  ec ]  V'
'Rotor angle            [ thetam ]   rad'
'Rotor speed           [ wm ]  rad/s'
'Electrical power     [ Pe ]  W'
'Stator currents                  [ isa  isb  isc ]  A'
'Stator currents                  [ iq  id ]  A'
'Field current                      [ ifd ]  A'
'Damper winding currents   [ ikq1  ikq2  ikd ]  A'
'Mutual fluxes                     [ phim_q   phim_d ]'
'Stator voltages                  [ vs_q   vs_d ]  V'
'Rotor angle deviation        [ d_theta ]  rad'
'Rotor speed                       [ wm ]  rad/s'
'Electrical power                 [ Pe ]  W'
'Rotor speed deviation       [ dw ]  pu'
'Rotor mechanical angle     [ theta ]   deg'
'Electromagnetic torque     [ Te ]  N.m'
'Load angle                         [ Delta ]  deg'
'Output active power          [ Peo ]  W'
'Output reactive power       [ Qeo ]  Var'
'Rotor currents    [ ira  irb  irc ]  A'
'Rotor currents    [ ir_q   ir_d  ]   A'
'Rotor fluxes       [ phir_q   phir_d ]  Wb'
'Rotor voltages   [ vr_q   vr_d ]  V'
'Stator currents   [ ia  ib  ic ]  A'
'Stator currents   [ is_q   is_d ]  A'
'Stator fluxes      [ phis_q  phis_d ]  Wb'
'Stator voltages   [ vs_q  vs_d ]  V'
'Rotor speed       [ wm ]  rad/s'
'Electromagnetic torque  [Te ]  N.m'
'Rotor angle        [ thetam ]  rad'
'Stator currents   [ ia, ib, ic ]  A'
'stator currents    [ is_q   is_d ]  A'
'Stator voltages   [ vs_q   vs_d ]   V'
'Hall effect       [ h_a  h_b  h_c ]'
'Rotor speed       [ wm ]   rad/s'
'Rotor angle        [ thetam ]  rad'
'Electromagnetic torque  [Te ]  N.m'
'lastType:'
                    };
                end
                set_param(object,'MaskPrompts',MaskPrompts);
