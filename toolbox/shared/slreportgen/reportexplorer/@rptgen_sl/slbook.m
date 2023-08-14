function fileName=slbook(varargin)






















    if((nargin>0)&&strcmp(varargin{1},'-showdialog'))
        if length(varargin)>1
            if ischar(varargin{2})
                try
                    sysName=getfullname(varargin{2});
                catch %#ok<CTCH>
                    error(message('RptgenSL:rptgen_sl:invalidSystemNameMsg',varargin{2}));
                end
            elseif isa(varargin{2},'Stateflow.Object')
                sysName=get(varargin{2},'ID');
            else
                sysName=varargin{2};
            end
        else
            sysName='';
        end
        fileName=launchDialog(sysName);
        return;
    end

    [isGUI,guiHandle]=getFlagValue(varargin,'-Dialog');
    [isSys,sysHandle]=getFlagValue(varargin,'-UseSystem');
    [isChart,chartID]=getFlagValue(varargin,'-UseChart');
    if~isempty(chartID)
        isSys=true;
        chartID=rptgen_sf.id2handle(chartID);
        if isa(chartID,'Stateflow.TruthTable')
            chartID=getParent(chartID);
        end
        sysHandle=locChart2System(chartID);
    elseif isempty(sysHandle)
        isSys=false;
    end

    adRG=rptgen.appdata_rg;
    adRG.HaltGenerate=false;

    if isGUI

        guiHandle.reportStart;
    end

    rpt=rptgen.loadRpt('slbook');
    if isempty(rpt)
        warning(message('RptgenSL:rptgen_sl:slBookNotFoundMsg'));
        fileName='';
    else

        setFlagValue(varargin,'-DirectoryName',rpt,'DirectoryType','other');
        setFlagValue(varargin,'-isIncrementFilename',rpt);
        setFlagValue(varargin,'-isDebug',rpt);
        setFlagValue(varargin,'-isView',rpt);




        mdlLoop=find(rpt,...
        '-depth',1,...
        '-isa','rptgen_sl.csl_mdl_loop');%#ok<GTARG>



        tPage=find(mdlLoop,...
        '-depth',1,...
        '-isa','rptgen.cfr_titlepage');%#ok<GTARG>

        if isSys
            oldCurrSys=gcs;
            set_param(0,'CurrentSystem',sysHandle);
            set(mdlLoop.LoopList(1),'MdlCurrSys',{sysHandle});
            rptgen.displayMessage('Setting MdlCurrSys',1);
        end

        [isMdlLoop,mdlLoopType]=getFlagValue(varargin,'-SysLoopType','all');%#ok-mlint
        if strcmpi(mdlLoopType,'all')||~isChart

            set(mdlLoop.LoopList(1),'SysLoopType',mdlLoopType);
            setFlagValue(varargin,'-isMask',mdlLoop.LoopList(1));
            setFlagValue(varargin,'-isLibrary',mdlLoop.LoopList(1));

            switch lower(mdlLoopType)
            case 'currentbelow'
                set(tPage,'Subtitle','Details for %<gcs> and below');
            case 'current'
                set(tPage,'Subtitle','Details for %<gcs>');
            case 'currentabove'
                set(tPage,'Subtitle','Details for %<gcs> and above');
            otherwise

            end
        else

            set(mdlLoop.LoopList(1),'SysLoopType','current');

            chtLoop=find(mdlLoop,'-isa','rptgen_sf.csf_chart_loop');
            set(chtLoop,'RuntimeLoopObjects',chartID);

            switch lower(mdlLoopType)
            case 'current'


                stateLoop=find(chtLoop,'-isa','rptgen_sf.csf_state_loop');
                set(stateLoop,'Depth','local');
                set(tPage,'Subtitle',getString(message('RptgenSL:rptgen_sl:chartDetailsLabel',sf('FullNameOf',chartID.ID,'/'))));
            case 'currentbelow'
                set(tPage,'Subtitle',getString(message('RptgenSL:rptgen_sl:chartDetailsAndBelowLabel',sf('FullNameOf',chartID.ID,'/'))));
            end
        end



        if~adRG.HaltGenerate

            fileName=rpt.execute;
        end

        if isSys
            set_param(0,'CurrentSystem',oldCurrSys);
        end
    end

    if isGUI

        guiHandle.reportEnd;
    end


    function setFlagValue(args,flagName,c,varargin)

        [isFoundValue,flagValue]=getFlagValue(args,flagName);
        if isFoundValue
            set(c,flagName(2:end),flagValue,varargin{:});
        end


        function[foundValue,flagValue]=getFlagValue(args,flagName,defaultValue)

            foundIdx=find(strcmp(args(1:2:end-1),flagName));
            if~isempty(foundIdx)
                foundValue=true;
                flagValue=args{2*foundIdx};
                if isa(flagValue,'java.lang.String')
                    flagValue=char(flagValue);
                end
            else
                foundValue=false;
                if nargin<3
                    flagValue=[];
                else
                    flagValue=defaultValue;
                end
            end


            function guiHandle=launchDialog(sysName)
                if isempty(sysName)
                    guiHandle=rptgen.internal.gui.SLBookDialog;
                    frameify(guiHandle);
                    setVisible(guiHandle);
                elseif ischar(sysName)
                    guiHandle=getDialog(sysName);

                    sysLoc=get_param(sysName,'Location');

                    guiHandle.setCurrentSystem(sysName,sysLoc(1),sysLoc(2));
                elseif(~isempty(meta.package.fromName('Stateflow')))...
                    sfName=sf('FullNameOf',sysName,'/');
                    sfID=sysName;
                    sysName=locChart2System(sysName);
                    guiHandle=getDialog(sysName);

                    sfObj=find(slroot,'ID',sfID);
                    if~isempty(findprop(sfObj,'Editor'))
                        edPos=sfObj.Editor.WindowPosition;
                        dlgWidth=getWidth(guiHandle);
                        dlgHeight=getHeight(guiHandle);

                        deltaX=(edPos(3)-dlgWidth)/2;
                        deltaY=(edPos(4)-dlgHeight)/2;

                        edX=edPos(1)+deltaX;
                        edY=edPos(2)+deltaY;


                        screenSize=get(0,'screensize');
                        if(edX<screenSize(1))
                            edX=screenSize(1);
                        elseif((edX+dlgWidth)>screenSize(3))
                            edX=screenSize(3)-(dlgWidth+dlgWidth/8);
                        end
                        if(edY<screenSize(2))
                            edY=screenSize(2);
                        elseif((edY+dlgHeight)>screenSize(4))
                            edY=screenSize(4)-(dlgHeight+dlgHeight/3);
                        end
                    else
                        sysLoc=get_param(sysName,'Location');
                        edX=sysLoc(1);
                        edY=sysLoc(2);
                    end



                    edX=edX-50;
                    edY=edY-50;
                    guiHandle.setCurrentChart(sfName,sfID,edX,edY);
                else
                    warning(message('RptgenSL:rptgen_sl:unrecognizedInputArgMsg'));
                    guiHandle=launchDialog([]);
                end


                function guiHandle=getDialog(sysName)
                    mdlName=get_param(bdroot(sysName),'Object');
                    dialogInstanceProp='SLBookDialog';
                    listenerInstanceProp='SLBookDialogListeners';
                    eventName='CloseEvent';




                    if~isempty(findprop(mdlName,dialogInstanceProp))
                        guiHandle=get(mdlName,dialogInstanceProp);
                    else
                        guiHandle=[];
                    end

                    if isempty(guiHandle)


                        guiHandle=rptgen.internal.gui.SLBookDialog;
                        guiHandle.frameify;

                        dListener(1)=Simulink.listener(mdlName,...
                        eventName,...
                        @closeListener);

                        if isempty(findprop(mdlName,listenerInstanceProp))
                            addprop(mdlName,listenerInstanceProp);
                        else

                        end
                        set(mdlName,listenerInstanceProp,dListener);

                        if isempty(findprop(mdlName,dialogInstanceProp))
                            addprop(mdlName,dialogInstanceProp);
                        else

                        end

                        set(mdlName,dialogInstanceProp,guiHandle);
                    end


                    function closeListener(EventSource,EventData)%#ok-mlint

                        dialogInstanceProp='SLBookDialog';
                        listenerInstanceProp='SLBookDialogListeners';

                        try
                            guiHandle=get(EventSource,dialogInstanceProp);
                            doClose(guiHandle);
                        catch %#ok<CTCH>
                            warning(message('RptgenSL:rptgen_sl:cannotCloseDialogMsg'));
                        end




                        delete(findprop(EventSource,listenerInstanceProp));
                        delete(findprop(EventSource,dialogInstanceProp));


                        function sysHandle=locChart2System(chartID)


                            if isempty(chartID)
                                sysHandle='';
                            elseif isnumeric(chartID)
                                sysHandle=locChart2System(rptgen_sf.id2handle(chartID));
                            elseif isa(chartID,'Stateflow.Chart')||...
                                isa(chartID,'Stateflow.StateTransitionTableChart')||...
                                isa(chartID,'Stateflow.TruthTableChart')
                                sysHandle=getfullname(chartID.up.up.Handle);
                            elseif isa(chartID,'Stateflow.Object')
                                sysHandle=locChart2System(chartID.Chart);
                            else
                                error(message('RptgenSL:rptgen_sl:invalidSFChartIdMsg'));
                            end
