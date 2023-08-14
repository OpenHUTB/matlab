function[rtnlist,nocompilation,append_independent_networks,network]=powersysdomain_netlist(action,arg)








    persistent NETLIST COMPILE_OPTION APPEND_INDEPENDENT_NETWORKS NETWORKS;

    if(strcmpi(action,'compile')&&~power_checklicense('false'))

        action='NoLicense';
    end

    switch action

    case 'StorageMethod'

        rtnlist='New';

    case 'Append'

        APPEND_INDEPENDENT_NETWORKS=1;

    case 'clear'

        NETLIST=[];
        rtnlist=NETLIST;
        nocompilation=0;
        NETWORKS=0;
        APPEND_INDEPENDENT_NETWORKS=arg;

    case 'compile'

        if APPEND_INDEPENDENT_NETWORKS
            if isempty(NETLIST)
                NETLIST=arg;
            else
                n=length(NETLIST.ConnectivityMatrix);
                m=length(arg.ConnectivityMatrix);
                [i1,j1,s1]=find(NETLIST.ConnectivityMatrix);
                [i2,j2,s2]=find(arg.ConnectivityMatrix);
                NETLIST.ConnectivityMatrix=sparse([i1;i2+n],[j1;j2+n],[s1;s2],m+n,m+n);
                NETLIST.PortHandles=[NETLIST.PortHandles;arg.PortHandles];
                NETLIST.BlockHandles=[NETLIST.BlockHandles;arg.BlockHandles];
            end
            rtnlist=NETLIST;
            nocompilation=0;
        else
            NETWORKS=NETWORKS+1;
            NETLIST=arg;
            powersysdomain_start(NETWORKS);
        end

    case 'NoEquivalentCircuit'

        NETWORKS=max(0,NETWORKS-1);

    case 'get'

        rtnlist=NETLIST;
        nocompilation=COMPILE_OPTION;
        append_independent_networks=APPEND_INDEPENDENT_NETWORKS;
        network=NETWORKS;

    case 'NoCompilation'

        COMPILE_OPTION=1;
        rtnlist=NETLIST;
        nocompilation=1;

    case 'Compilation'

        COMPILE_OPTION=0;
        rtnlist=NETLIST;
        nocompilation=0;

    case 'SPSnetlist'

        nocompilation=0;
        system=arg;

        UnconnectedLineMsg=get_param(system,'UnconnectedLineMsg');
        UnconnectedOutputMsg=get_param(system,'UnconnectedOutputMsg');
        UnconnectedInputMsg=get_param(system,'UnconnectedInputMsg');
        Dirty=get_param(system,'Dirty');

        try
            set_param(system,'UnconnectedLineMsg','none');
            set_param(system,'UnconnectedOutputMsg','none');
            set_param(system,'UnconnectedInputMsg','none');
            NETLIST=[];
            COMPILE_OPTION=1;%#ok disable the SPS compilation process
            APPEND_INDEPENDENT_NETWORKS=2;


            set_param(system,'SimulationCommand','update');

        catch ME
            COMPILE_OPTION=0;%#ok reset the SPS compilation process
            APPEND_INDEPENDENT_NETWORKS=0;


            if isempty(NETLIST)
                if~isempty(ME.cause)
                    MEcause=ME.cause{1};
                    Erreur.message=MEcause.message;
                    Erreur.identifier=MEcause.identifier;
                else
                    Erreur.message=ME.message;
                    Erreur.identifier='SpecializedPowerSystems:Powersysdomain:Netlist';
                end
                psberror(Erreur);
            end
        end

        COMPILE_OPTION=0;


        if~isempty(NETLIST)
            rtnlist=POWERSYS.Netlist(NETLIST);
        else
            rtnlist=[];
        end


        set_param(system,'UnconnectedLineMsg',UnconnectedLineMsg);
        set_param(system,'UnconnectedOutputMsg',UnconnectedOutputMsg);
        set_param(system,'UnconnectedInputMsg',UnconnectedInputMsg);
        set_param(system,'Dirty',Dirty);


    case 'NoLicense'

        COMPILE_OPTION=1;
        rtnlist=NETLIST;
        nocompilation=1;



        sldiagviewer.reportError('Compiler error due to missing Simscape Electrical license.  Check installation and license.','Component','SimscapeElectrical','Category','Compiler');

    end