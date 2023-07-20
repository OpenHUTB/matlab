function updateHandler(this,event,bkname)





    switch event


    case 'attach'
        registerPropList(this,'NoDuplicate','All',[]);


        mdl=this.getModel;
        if~isempty(mdl)&&~any(strcmp(getConfigSets(mdl),bkname))
            newcs=copy(getActiveConfigSet(mdl));
            newcs.Name=bkname;
            attachConfigSet(mdl,newcs);
        end


    case 'activate'

        oldThis=SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC.upgradeFromRTWin([]);
        if~isempty(oldThis)
            props=oldThis.getProp;
            for i=1:length(props)
                try
                    this.set(props{i},oldThis.get(props{i}));
                catch
                end
            end
        end


        setSLDRTCSParams(this,false);


    case 'switch_target'

        setSLDRTCSParams(this,true);


    case 'deselect_target'
    end



    function setSLDRTCSParams(this,default)



        cs=this.getConfigSet;
        if isempty(cs)
            return;
        end




        tgarch=SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC.getTargetArch();
        precomplibloc=fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))),'lib',tgarch);
        devtype='Intel->x86-64 (Linux 64)';


        reqset={...

        'TargetPreCompLibLocation',precomplibloc;
        'TargetLibSuffix','_sldrt.a';


        'ExtMode','on';
        'ExtModeTransport',0;
        'ExtModeMexFile','sldrtext';
        'ExtModeIntrfLevel','Level1';


        'ProdHWDeviceType',devtype;
        'ProdEqTarget','on';
        };


        for i=1:size(reqset,1)
            slConfigUISetEnabled(this,cs,reqset{i,1},'on');
            set_param(cs,reqset{i,:});
            slConfigUISetEnabled(this,cs,reqset{i,1},'off');
        end
        slConfigUISetEnabled(this,cs,'HardwareBoard','off');



        if~default
            return;
        end


        if~strcmpi(get_param(cs,'SolverType'),'Fixed-step')
            switch(get_param(cs,'Solver'))
            case 'VariableStepDiscrete'
                slv='FixedStepDiscrete';
            case{'ode15s','ode23t'}
                slv='ode14x';
            case{'ode23','ode23s','ode23tb'}
                slv='ode3';
            otherwise
                slv='ode5';
            end
            set_param(cs,'Solver',slv);
        end



        set_param(cs,'MaxIdLength',95,...
        'RTWCompilerOptimization','on',...
        'SupportVariableSizeSignals','on');


        mdl=cs.getModel;
        if~isempty(mdl)
            set_param(mdl,'ExtModeAutoUpdateStatusClock','on');
        end
