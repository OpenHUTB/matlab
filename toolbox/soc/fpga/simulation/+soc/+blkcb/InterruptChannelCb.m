function varargout=InterruptChannelCb(varargin)




    if nargout==0
        feval(varargin{:});
    else
        [varargout{1:nargout}]=feval(varargin{:});
    end
end


function MaskParamCb(paramName,blkH)
    cbH=eval(['@',paramName,'Cb']);
    soc.blkcb.cbutils('MaskParamCb',paramName,blkH,cbH);
end


function InitFcn(~)


    if~builtin('license','checkout','SoC_Blockset')
        error(message('soc:utils:NoLicense'));
    end

    soc.internal.HWSWMessageTypeDef();
end

function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function PreCopyFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
    if~isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped'),return;end



    intCh=find_system(get(bdroot(blkH),'Name'),'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','Interrupt Channel');
    if~isempty(intCh)
        error(message('soc:msgs:MultipleIntChannel'));
    end
end


function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    MIN_NUM_INTS=getMinNumInt();
    MAX_NUM_INTS=getMaxNumInt();
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    sysH=bdroot(blkH);

    SetMaskHelp(blkH);

    try
        assert(blkP.NumInterrupts>=MIN_NUM_INTS,message('soc:msgs:MinInterruptsExceeded',MIN_NUM_INTS));
        assert(blkP.NumInterrupts<=MAX_NUM_INTS,message('soc:msgs:MaxInterruptsExceeded',MAX_NUM_INTS));

        if blkP.NumInterrupts~=length(blkP.IntTableNames)
            msg=message('soc:msgs:MustEditIntTable',blkPath);
            switch get_param(sysH,'SimulationStatus')
            case{'updating','initializing','running'}
                error(msg);
            otherwise
                error(msg);
            end
        end



        numReg=blkP.NumInterrupts;
        for r=1:numReg
            hreg=[blkPath,'/Interrupt',num2str(r)];
            set_param(hreg,'Trigger',blkP.IntTableTriggers{r});
        end

        for r=numReg+1:MAX_NUM_INTS
            hreg=[blkPath,'/Interrupt',num2str(r)];
            set_param(hreg,'Trigger','None');
        end

        update_subsystem_ports(blkH,blkPath,sysH,blkP);
        SetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.InterruptChannel');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function AddTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    MAX_NUM_INTS=getMaxNumInt();
    numRows=tabC.getNumberOfRows();
    assert(numRows<MAX_NUM_INTS,message('soc:msgs:MaxInterruptsExceeded',MAX_NUM_INTS));

    rowIndex=numRows+1;
    rowPrio=num2str(rowIndex);
    rowName=sprintf('interrupt%d',rowIndex);
    while(~isempty(find(contains(blkP.IntTableNames,rowName),1)))
        rowIndex=rowIndex+1;
        rowName=sprintf('interrupt%d',rowIndex);
    end

    tabC.addRow(rowName,'Rising edge',rowPrio);

    SyncTableParams(blkH);
end

function DeleteTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'descend');

    MIN_NUM_INTS=getMinNumInt();
    assert((tabC.getNumberOfRows()-numRows)>=MIN_NUM_INTS,message('soc:msgs:MinInterruptsExceeded',MIN_NUM_INTS));

    for i=1:numRows
        tabC.removeRow(rowIndex(i));
    end

    ResetPriorityColumn(blkH);

    SyncTableParams(blkH);

end

function ShiftTableRowUpCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'ascend');

    for i=1:numRows
        if rowIndex(i)==1
            break;
        end
        tabC.swapRows(rowIndex(i)-1,rowIndex(i));
    end

    ResetPriorityColumn(blkH);

    SyncTableParams(blkH);
end

function ShiftTableRowDownCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'descend');

    for i=1:numRows
        if rowIndex(i)==tabC.getNumberOfRows()
            break;
        end
        tabC.swapRows(rowIndex(i)+1,rowIndex(i));
    end

    ResetPriorityColumn(blkH);

    SyncTableParams(blkH);
end

function EditTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    index=tabC.getChangedCells();
    if~isempty(index)
        blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
        rowIndex=index{1}(1);
        colIndex=index{1}(2);
        switch colIndex
        case 1

            val=tabC.getTableCell(index{1}).Value;
            if~isIntNameUnique(tabC,val,rowIndex)
                tabC.setValue(index{1},blkP.IntTableNames{rowIndex});
                error(message('soc:msgs:IntNameInUse',val));
            end
            if isempty(regexp(val,'^[A-Za-z]\w+$','ONCE'))
                tabC.setValue(index{1},blkP.IntTableNames{rowIndex});
                error(message('ERRORHANDLER:utils:InvalidInputParameter','Interrupt Channel',val,'Interrupt name'));
            end
        case 2
        end

        SyncTableParams(blkH);
    end

end

function isUnique=isIntNameUnique(tabC,name,rowIndex)
    isUnique=true;
    numRows=tabC.getNumberOfRows();
    for i=1:numRows
        intName=tabC.getTableCell([double(i),1]).Value;
        if isequal(intName,name)&&i~=rowIndex
            isUnique=false;
            break;
        end
    end
end

function ResetPriorityColumn(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    numRows=tabC.getNumberOfRows();
    priorityIdx=tabC.getNumberOfColumns();

    for i=1:numRows
        tabC.setValue([i,priorityIdx],num2str(i));
    end
end

function SyncTableParams(blkH)

    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('InterruptTable');
    numRows=tabC.getNumberOfRows();
    numCols=tabC.getNumberOfColumns();

    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
    blkP.NumInterrupts=numRows;
    pMap=containers.Map((1:numCols-1),{'IntTableNames','IntTableTriggers'});
    for i=1:numCols-1
        col=pMap(i);
        blkP.(col)=[];
        for j=1:numRows
            blkP.(col){j}=tabC.getValue([double(j),double(i)]);
        end
        set_param(blkH,col,['{',sprintf('''%s'' ',blkP.(col){:}),'}']);
    end
    set_param(blkH,'NumInterrupts',num2str(blkP.NumInterrupts));
end

function ResetTableCb(blkH)
    maskObj=Simulink.Mask.get(blkH);


    tabC=maskObj.getDialogControl('InterruptTable');
    numCols=tabC.getNumberOfColumns();

    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
    tabS=[];


    if~isequal(tabC.getColumn(numCols).Name,'Priority')
        tabC.addColumn('Name','Priority','Type','edit','Enabled','off');
        numCols=tabC.getNumberOfColumns();
    end


    pMap=containers.Map((1:numCols-1),{'IntTableNames','IntTableTriggers'});
    for i=1:blkP.NumInterrupts

        for j=1:numCols-1
            col=pMap(j);
            tabR{j}=sprintf('''%s''',blkP.(col){i});%#ok<*AGROW>
        end

        tabR{end+1}=sprintf('''%d''',i);

        tabR=strjoin(string(tabR),',');
        if isempty(tabS)
            tabS=tabR;
        else
            tabS=strcat(tabS,';',tabR);
        end
    end


    tabC.setData(sprintf("{%s}",tabS));

end

function SetMaskHelp(blkH)

    helpTopic='soc_interruptchannel';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH,blkP)




    numInt=blkP.NumInterrupts;
    inputLabels=cell(numInt*2,1);
    outputLabels=cell(numInt*2,1);
    pidx=0;
    for r=1:numInt
        pidx=pidx+1;
        inputLabels{pidx}=r;
        outputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=blkP.IntTableNames{r};
        outputLabels{pidx}=blkP.IntTableNames{r};
    end

    HWlabel=sprintf('text(0.02,0.95,''{\\bfHW}'',''horizontalAlignment'',''left'', ''texmode'',''on'');');
    SWlabel=sprintf('text(0.98,0.95,''{\\bfSW}'',''horizontalAlignment'',''right'',''texmode'',''on'');');
    inPorts=sprintf('port_label(''input'', %d, ''%s'');\n',inputLabels{:});
    outPorts=sprintf('port_label(''output'', %d, ''%s'');\n',outputLabels{:});
    fullIcon=sprintf('%s\n%s\n%s\n%s\n',HWlabel,SWlabel,inPorts,outPorts);
    set_param(blkH,'MaskDisplay',fullIcon);
end




function update_subsystem_ports(blkH,blkPath,sysH,blkP)




    if(soc.blkcb.cbutils('SimStatusIsRunning',blkH,sysH))
        return;
    end
    MAX_NUM_INTS=getMaxNumInt();
    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInGrounds=find_system(blkPath,commonargs{:},'BlockType','Ground');
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport');
    allOutTerms=find_system(blkPath,commonargs{:},'BlockType','Terminator');

    interfaceChange=false;
    if blkP.NumInterrupts<length(allInPorts)

        interfaceChange=true;
        for pidx=blkP.NumInterrupts+1:MAX_NUM_INTS-length(allInGrounds)
            wrname=['in_int',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Ground','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','constant'));
            set_param(newwrblk{1},'Name',wrname);
        end
    elseif blkP.NumInterrupts>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allInPorts)+1:blkP.NumInterrupts
            wrname=['in_int',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Inport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
            set_param(newwrblk{1},'Name',wrname);
        end
    else

    end
    if blkP.NumInterrupts<length(allOutPorts)

        interfaceChange=true;
        for pidx=blkP.NumInterrupts+1:MAX_NUM_INTS-length(allOutTerms)
            rdname=['out_int',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Terminator','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
            set_param(newrdblk{1},'Name',rdname);
        end
    elseif blkP.NumInterrupts>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allOutPorts)+1:blkP.NumInterrupts
            rdname=['out_int',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Outport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','outport'));
            set_param(newrdblk{1},'Name',rdname);
        end
    else

    end





































    if interfaceChange



        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end

function MAX_NUM_INTS=getMaxNumInt()
    MAX_NUM_INTS=16;
end

function MIN_NUM_INTS=getMinNumInt()
    MIN_NUM_INTS=1;
end



