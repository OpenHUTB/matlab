function simrfV2filter(block,action)






    top_sys=bdroot(block);
    if strcmpi(top_sys,'simrfV2elements')
        return;
    end




    switch(action)
    case 'simrfInit'

        if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
            {'running','paused'}))
            return
        end


        MaskWSValues=simrfV2getblockmaskwsvalues(block);

        MaskDisplay='';



        hasUnderMaskGnd=~isempty(find_system(block,...
        'LookUnderMasks','all','FollowLinks','on',...
        'SearchDepth',1,'Parent',block,'Name','Gnd1'));
        BoxBlock=find_system(block,'RegExp','on',...
        'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,...
        'Parent',block,'Name','(S|F)2PORT_RF');
        if~isempty(BoxBlock)
            [~,BlkName]=fileparts(BoxBlock{1});
            BoxType=BlkName(1);
        else
            BoxType='';
        end

        switch lower(MaskWSValues.InternalGrounding)
        case 'on'

            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
            1,{'1'},1,{'2'},true);
            set_param(block,'MaskDisplay',MaskDisplay)

            if~hasUnderMaskGnd
                portLbl={'1-','2-'};
                gndName={'Gnd1','Gnd2'};
                if~isempty(BoxType)
                    fromBlk=[BoxType,'2PORT_RF'];
                    portSide={'LConn','RConn'};
                    portIdx=2;
                else
                    fromBlk='Node';
                    portSide={'RConn','RConn'};
                    portIdx=1;
                end

                for p_idx=1:2

                    simrfV2repblk(struct('RepBlk',portLbl{p_idx},...
                    'SrcBlk','simrfV2elements/Gnd',...
                    'SrcLib','simrfV2elements',...
                    'DstBlk',gndName{p_idx}),block);

                    simrfV2connports(struct(...
                    'SrcBlk',fromBlk,...
                    'SrcBlkPortStr',portSide{p_idx},...
                    'SrcBlkPortIdx',portIdx,...
                    'DstBlk',gndName{p_idx},...
                    'DstBlkPortStr','LConn',...
                    'DstBlkPortIdx',1),block);
                end
            end

        case 'off'

            MaskDisplay=simrfV2_add_portlabel(MaskDisplay,...
            2,{'1'},2,{'2'},false);
            set_param(block,'MaskDisplay',MaskDisplay)
            if hasUnderMaskGnd
                portLbl={'1-','2-'};
                portNum={'3','4'};
                gndName={'Gnd1','Gnd2'};
                sysSide={'Left','Right'};
                if~isempty(BoxType)
                    fromBlk=[BoxType,'2PORT_RF'];
                    portSide={'LConn','RConn'};
                    portIdx=2;
                else
                    fromBlk='Node';
                    portSide={'RConn','RConn'};
                    portIdx=1;
                end
                for p_idx=1:2
                    simrfV2repblk(struct(...
                    'RepBlk',gndName{p_idx},...
                    'SrcBlk','nesl_utility_internal/Connection Port',...
                    'SrcLib','nesl_utility_internal',...
                    'DstBlk',portLbl{p_idx},...
                    'Param',{{'Side',sysSide{p_idx},...
                    'Orientation','Up',...
                    'Port',portNum{p_idx}}}),block);
                    simrfV2connports(struct(...
                    'SrcBlk',fromBlk,...
                    'SrcBlkPortStr',portSide{p_idx},...
                    'SrcBlkPortIdx',portIdx,...
                    'DstBlk',portLbl{p_idx},...
                    'DstBlkPortStr','RConn',...
                    'DstBlkPortIdx',1),block);
                end
            end
        end


        if strcmpi(MaskWSValues.DesignMethod,'Ideal')
            designData.DesignMethod=MaskWSValues.DesignMethod;
            designData.ResponseType=MaskWSValues.ResponseType;
            designData.Implementation=MaskWSValues.Implementation;


            simrfV2_filt_f2port_setup(block,...
            simrfV2getblockmaskwsvalues(block));
            uData=get_param(block,'UserData');
            if~isequal(designData,uData)
                set_param(block,'UserData',designData);
            end
        elseif strcmpi(MaskWSValues.DesignMethod,'InverseChebyshev')
            designData=simrfV2_filt_design(MaskWSValues);


            simrfV2_filt_s2box_setup(block,MaskWSValues.Rsrc,...
            MaskWSValues.Rload,designData)

            set_param(block,'UserData',designData);
        else

            designData=simrfV2_filt_design(MaskWSValues);
            if strcmpi(MaskWSValues.Implementation,'Transfer function')


                simrfV2_filt_s2box_setup(block,MaskWSValues.Rsrc,...
                MaskWSValues.Rload,designData)

                set_param(block,'UserData',designData);
            else

                topology=lower(sprintf('lc%s%s',...
                designData.ResponseType,designData.Implementation(4:end)));
                userData=get_param(block,'UserData');




                if isempty(userData)||...
                    ~isa(userData,'rffilter')||...
                    ~isfield(userData.DesignData,'Topology')||...
                    ~strcmpi(topology,userData.DesignData.Topology)||...
                    any(size(designData.DesignData.Inductors)~=...
                    size(userData.DesignData.Inductors))||...
                    any(abs(designData.DesignData.Inductors-...
                    userData.DesignData.Inductors)>=...
                    100*eps(userData.DesignData.Inductors))||...
                    any(size(designData.DesignData.Capacitors)~=...
                    size(userData.DesignData.Capacitors))||...
                    any(abs(designData.DesignData.Capacitors-...
                    userData.DesignData.Capacitors)>=...
                    100*eps(userData.DesignData.Capacitors))||...
                    MaskWSValues.needRedraw==true

                    simrfV2_lcladder_setup(block,topology,...
                    designData.DesignData.Inductors,...
                    designData.DesignData.Capacitors)
                    set_param(block,'UserData',designData);
                    set_param(block,'needRedraw','0')
                end
            end
        end
    end

end
