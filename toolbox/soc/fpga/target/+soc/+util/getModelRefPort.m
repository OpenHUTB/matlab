function hsbModelRefPort=getModelRefPort(hsbSubsysTop,hsbSubsystem,ports,portNum,dir)





    if strcmpi(hsbSubsysTop,hsbSubsystem)


        hsb_mdlref_port_list=find_system(ports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Port',num2str(portNum));
        hsb_mdlref_port=hsb_mdlref_port_list{1};
    else
        if strcmp(dir,'in')
            hsbSubsysPortType='Inport';
            hsbLineType='Outport';
        elseif strcmp(dir,'out')
            hsbSubsysPortType='Outport';
            hsbLineType='Inport';
        end


        hsbSubsysTopPort=find_system(hsbSubsysTop,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'lookundermasks','all','BlockType',hsbSubsysPortType,'Port',num2str(portNum));
        hsbSubsysTopPort=hsbSubsysTopPort{1};
        hl_hsbSubsysTopPort=get_param(hsbSubsysTopPort,'LineHandles');
        topPortLineHandle=hl_hsbSubsysTopPort.(hsbLineType);
        if topPortLineHandle==-1
            hsbSubsysTopPortName=strtrim(get_param(hsbSubsysTopPort,'Name'));


            mdlRefPort=find_system(ports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Name',hsbSubsysTopPortName);
            if~isempty(mdlRefPort)
                mdlRefPort=mdlRefPort{1};
                hsb_mdlref_port_num=str2double(get_param(mdlRefPort,'Port'));
            else


                hsb_mdlref_port_num=[];
            end
        else
            if strcmp(dir,'in')
                [~,hsb_mdlref_port_num,~,~]=soc.util.getDstBlk(topPortLineHandle);
                hsb_mdlref_port_num=hsb_mdlref_port_num{:};
            elseif strcmp(dir,'out')
                [~,hsb_mdlref_port_num,~,~]=soc.util.getSrcBlk(topPortLineHandle);
            end
        end
        if~isempty(hsb_mdlref_port_num)


            hsb_mdlref_port_list=find_system(ports,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Port',num2str(hsb_mdlref_port_num));
            hsb_mdlref_port=hsb_mdlref_port_list{1};
        else
            hsb_mdlref_port='';
        end
    end
    hsbModelRefPort=hsb_mdlref_port;
end

