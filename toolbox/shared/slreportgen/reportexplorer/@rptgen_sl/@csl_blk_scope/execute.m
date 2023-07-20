function out=execute(c,d,varargin)







    adSL=rptgen_sl.appdata_sl;

    xyBlocks=findContextBlocks(adSL,'MaskType','\<XY scope.\>');


    scopeBlockTypes=Simulink.scopes.getSupportedBlocks('SimulinkReportGenerator');
    unifiedScopeBlocks=[];
    for indx=1:numel(scopeBlockTypes)
        unifiedScopeBlocks=[unifiedScopeBlocks;findContextBlocks(adSL,scopeBlockTypes{indx}{:})];%#ok<AGROW>
    end


    if(exist(fullfile(matlabroot,'toolbox','shared','slcontrollib'),'dir')==7)
        checkpackScopeTypes=checkpack.absCheckVisual.getAllBlocks;
    else
        checkpackScopeTypes={};
    end
    slcontrolScopeBlocks=[];
    for indx=1:numel(checkpackScopeTypes)
        slcontrolScopeBlocks=[slcontrolScopeBlocks;findContextBlocks(adSL,checkpackScopeTypes{indx}{:})];%#ok<AGROW>
    end

    out=createDocumentFragment(d);


    for i=1:length(xyBlocks)
        figHandle=locXYHandle(xyBlocks{i});
        if ishandle(figHandle)
            ihc=c.findInvertState(figHandle);
            if ihc
                oldLineColors=patternlines(figHandle);
                oldFigColor=get(figHandle,'Color');
                set(figHandle,'color',[1,1,1]);
            end
            gTag=c.gr_makeGraphic(d,figHandle,xyBlocks{i});

            if ihc
                set(figHandle,'color',oldFigColor);
                patternlines(figHandle,oldLineColors);
            end

            if~isempty(gTag)
                out.appendChild(gTag);
            end
        end
    end


    for i=1:length(unifiedScopeBlocks)
        hScopeBlock=unifiedScopeBlocks{i};
        [scopeFramework,closeWhenDone]=locUnifiedScopeHandle(c,hScopeBlock);
        out=takeUnifiedScopeSnapshot(out,c,d,scopeFramework,closeWhenDone,hScopeBlock);
    end


    for i=1:length(slcontrolScopeBlocks)
        hScopeBlock=slcontrolScopeBlocks{i};
        [scopeFramework,closeWhenDone]=locControlDesignScopeHandle(c,hScopeBlock);
        out=takeUnifiedScopeSnapshot(out,c,d,scopeFramework,closeWhenDone,hScopeBlock);
    end


    function figHandle=locXYHandle(xyBlock)

        allFigs=findall(allchild(0),'flat',...
        'Tag','SIMULINK_XYGRAPH_FIGURE');

        try
            blkHandle=get_param(xyBlock,'Handle');
        catch
            blkHandle=-1;
        end

        figHandle=-1;
        for i=1:length(allFigs)
            ud=get(allFigs(i),'UserData');
            if isfield(ud,'Block')&&isequal(ud.Block,blkHandle)
                figHandle=allFigs(i);
                break;
            end
        end


        function oldVals=patternlines(figHandle,patternVals)






            lineHandles=findall(allchild(figHandle),...
            'type','line');

            if nargin>1
                set(lineHandles,patternVals{:});
            else
                newColor=[.1,.1,.1];
                nLines=length(lineHandles);

                if nLines==1

                    oldVals={'color',get(lineHandles,'color'),...
                    'linewidth',get(lineHandles,'linewidth')};
                    set(lineHandles,...
                    'color',newColor,...
                    'linewidth',2);
                else
                    oldVals={{'color'},get(lineHandles,'color'),...
                    {'linestyle'},get(lineHandles,'linestyle'),...
                    {'linewidth'},get(lineHandles,'linewidth')};

                    set(lineHandles,'color',newColor);

                    set(lineHandles(2:4:end),'linestyle','--');
                    set(lineHandles(3:4:end),'linestyle',':');
                    set(lineHandles(4:4:end),'linestyle','-.');

                    lineWidth=1;
                    for i=1:4:nLines
                        lineWidth=lineWidth+1;
                        set(lineHandles(i:min(i+4,nLines)),'linewidth',lineWidth);
                    end
                end
            end


            function[scopeFramework,openedScope]=locUnifiedScopeHandle(c,block)


                sc=get_param(block,'ScopeConfiguration');
                hScopeSpec=get_param(block,'ScopeSpecificationObject');
                openedScope=false;
                scopeFramework=getUnifiedScope(hScopeSpec);
                if~sc.Visible
                    if c.isForceOpen
                        sc.Visible=true;
                        openedScope=true;

                        scopeFramework=getUnifiedScope(hScopeSpec);
                    else
                        scopeFramework=[];
                    end
                end



                function[scopeFramework,openedScope]=locControlDesignScopeHandle(c,scopeBlock)

                    hBlk=get_param(scopeBlock,'Object');


                    cls=hBlk.DialogControllerArgs;
                    hCoreBlk=feval(strcat(cls,'.getCoreBlock'),hBlk);

                    scopeFramework=getappdata(hCoreBlk,'BlockVisualization');
                    if isempty(scopeFramework)||~ishandle(scopeFramework)
                        isVisible=false;
                    else
                        isVisible=uiservices.onOffToLogical(get(scopeFramework.Parent,'Visible'));
                    end
                    openedScope=false;
                    if~isVisible
                        if c.isForceOpen
                            checkpack.absCheckDlg.openBlkView(hBlk);
                            openedScope=true;

                            scopeFramework=getappdata(hCoreBlk,'BlockVisualization');
                        else
                            scopeFramework=[];
                        end
                    end


                    function out=takeUnifiedScopeSnapshot(out,c,d,fw,closeWhenDone,hScopeBlock)
                        gTag='';




                        if~isempty(fw)&&(fw.ScopeCfg.showPrintAction('menu'))&&~screenMsg(fw)
                            if c.AutoscaleScope
                                p=getExtInst(fw,'Tools','Plot Navigation');
                                if~isempty(p)
                                    p.performAutoscale(false,true);
                                end
                            end

                            tempHandle=printToFigure(fw.Visual,false);
                            if ishandle(tempHandle)
                                if strcmp(c.findInvertState(tempHandle),'on')
                                    patternlines(tempHandle);
                                end
                                gTag=c.gr_makeGraphic(d,tempHandle,hScopeBlock);
                                delete(tempHandle);
                            end
                        end


                        if~isempty(gTag)
                            out.appendChild(gTag);
                        end


                        if closeWhenDone&&~isempty(fw)
                            fw.visible('Off');
                        end

