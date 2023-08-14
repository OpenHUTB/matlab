function schema




    mlock;

    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'appdata_sl',pkgRG.findclass('appdata'));

    p=newSchema(h,'CurrentModel','MATLAB array','');
    p.getFunction=@gvCurrentModel;
    p.setFunction=@setCurrentModel;
    p=newSchema(h,'CurrentSystem','MATLAB array','');
    p.getFunction=@gvCurrentSystem;
    p=newSchema(h,'CurrentBlock','MATLAB array','');
    p.getFunction=@gvCurrentBlock;
    p=newSchema(h,'CurrentSignal','double',-1);
    p.getFunction=@gvCurrentSignal;
    p=newSchema(h,'CurrentAnnotation','double',-1);
    p.getFunction=@gvCurrentAnnotation;
    p=newSchema(h,'CurrentWorkspaceVar','MATLAB array',[]);
    p.getFunction=@gvCurrentWorkspaceVar;
    p=newSchema(h,'CurrentDataDictionary','MATLAB array',[]);
    p.getFunction=@gvCurrentDataDictionary;

    newSchema(h,'CurrentSignalGroup','MATLAB array','');

    newSchema(h,'Context','ustring','');

    p=newSchema(h,'ReportedSystemList','MATLAB array',{});
    p.getFunction=@gvReportedSystemList;
    p=newSchema(h,'ReportedBlockList','MATLAB array',{});
    p.getFunction=@gvReportedBlockList;
    p=newSchema(h,'ReportedSignalList','double vector');
    p.getFunction=@gvReportedSignalList;

    newSchema(h,'RtwCompiledModels','MATLAB array',{});

    p=newSchema(h,'PreRunOpenModels','double vector',nan);
    p.getFunction=@gvPreRunOpenModels;


    newSchema(h,'ReportedDocs','MATLAB array',{});


    newSchema(h,'ReportedDocsUseIDs','ustring','off');
    newSchema(h,'ReportedDocsUseDOORS','ustring','off');

    newSchema(h,'CompiledModelList','java.util.Stack',java.util.Stack());
    newSchema(h,'FailedCompiledModelList','java.util.Stack',java.util.Stack());


    function p=newSchema(h,name,dataType,factoryValue)

        if strcmp(dataType,'double vector')
            dataType='MATLAB array';

        end

        p=schema.prop(h,name,dataType);
        p.AccessFlags.Init='on';
        p.AccessFlags.Reset='on';
        p.AccessFlags.AbortSet='off';

        if nargin>3
            p.FactoryValue=factoryValue;
        end


        function val=setCurrentModel(this,val)

            this.CurrentSystem='';




            this.ReportedSystemList={};
            this.ReportedBlockList={};
            this.ReportedSignalList=[];
            this.ReportedDocs={};
            compileModelIfSpecified(this,val);


            function val=gvCurrentModel(this,val)

                compileModelIfSpecified(this,val);


                function val=gvCurrentSystem(this,val)

                    compileModelIfSpecified(this,val);


                    function val=gvCurrentBlock(this,val)

                        compileModelIfSpecified(this,val);


                        function compileModelIfSpecified(this,val)





                            try

                                adRG=rptgen.appdata_rg;
                                if(adRG.RootComponent.CompileModel&&strcmpi(adRG.GenerationStatus,'report'))
                                    model=bdroot(val);
                                    try
                                        if~this.FailedCompiledModelList.contains(model)

                                            rptgen_sl.compileModel(model);


                                            if~strcmp(get_param(model,'SimulationStatus'),'stopped')
                                                CompiledModelList=this.CompiledModelList;
                                                if~CompiledModelList.contains(model)
                                                    CompiledModelList.push(model);
                                                end
                                            end
                                        end
                                    catch %#ok
                                        this.FailedCompiledModelList.push(model);
                                    end

                                end

                            catch ex %#ok
                            end


                            function val=gvCurrentWorkspaceVar(this,val)

                                if isempty(val)
                                    currSys=this.CurrentSystem;
                                    if~isempty(currSys)
                                        try
                                            variableList=Simulink.findVars(currSys,...
                                            'SearchMethod','cached','ReturnResolvedVar',true);
                                            if~isempty(variableList)
                                                val=variableList(1);
                                            end
                                        catch me %#ok
                                            val=[];
                                        end
                                    end
                                end


                                function val=gvCurrentDataDictionary(this,val)

                                    if isempty(val)
                                        try
                                            looper=rptgen_sl.csl_data_dict_loop();
                                            dictionaries=looper.loop_getLoopObjects();
                                            if~isempty(dictionaries)
                                                val=dictionaries(1);
                                            end
                                        catch me %#ok
                                            val=[];
                                        end
                                    end



                                    function val=gvCurrentAnnotation(this,val)

                                        if val==-1
                                            currSys=this.CurrentSystem;
                                            if~isempty(currSys)
                                                aList=find_system(currSys,...
                                                'findall','on',...
                                                'SearchDepth',1,...
                                                'FollowLinks','on',...
                                                'LookUnderMasks','all',...
                                                'type','annotation');
                                                if~isempty(aList)
                                                    val=aList(1);
                                                end
                                            end
                                        end


                                        function val=gvCurrentSignal(this,val)

                                            if val==-1
                                                currSys=this.CurrentSystem;
                                                if~isempty(currSys)
                                                    sList=find_system(currSys,...
                                                    'findall','on',...
                                                    'SearchDepth',1,...
                                                    'FollowLinks','on',...
                                                    'LookUnderMasks','all',...
                                                    'Type','port',...
                                                    'PortType','outport');
                                                    if~isempty(sList)
                                                        val=sList(1);
                                                    end
                                                end
                                            end


                                            function val=gvReportedSystemList(this,val)

                                                if isempty(val)
                                                    mdlName=this.CurrentModel;

                                                    if~isempty(mdlName)
                                                        loopObj=rptgen_sl.rpt_mdl_loop_options('MdlName',mdlName,...
                                                        'MdlCurrSys',{'$top'},...
                                                        'SysLoopType','all');
                                                        val=loopObj.getReportedSystems(mdlName);
                                                    end
                                                end


                                                function val=gvReportedBlockList(this,val)

                                                    if isempty(val)
                                                        val=unique(find_system(this.ReportedSystemList,...
                                                        'SearchDepth',1,...
                                                        'FollowLinks','on',...
                                                        'LookUnderMasks','all',...
                                                        'type','block'));

                                                        this.ReportedBlockList=val;
                                                    end


                                                    function val=gvReportedSignalList(this,val)


                                                        if isempty(val)
                                                            val=unique(find_system(this.ReportedSystemList,...
                                                            'findall','on',...
                                                            'SearchDepth',1,...
                                                            'FollowLinks','on',...
                                                            'LookUnderMasks','all',...
                                                            'type','port',...
                                                            'porttype','outport'));

                                                            this.ReportedSignalList=val;
                                                        end



                                                        function val=gvPreRunOpenModels(this,val)

                                                            if~isempty(val)&&all(isnan(val))
                                                                val=find_system(0,...
                                                                'SearchDepth',1,...
                                                                'type','block_diagram');

                                                                this.PreRunOpenModels=val;
                                                            end



