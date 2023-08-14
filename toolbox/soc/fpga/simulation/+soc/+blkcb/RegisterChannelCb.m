function varargout=RegisterChannelCb(varargin)




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
    soc.internal.HWSWMessageTypeDef();
end

function LoadFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end

function PreSaveFcn(blkH)
    if soc.blkcb.cbutils('IsLibContext',blkH),return;end
end


function MaskInitFcn(blkH,~)%#ok<*DEFNU>
    persistent hadError
    if isempty(hadError)
        hadError=false;
    end

    if soc.blkcb.cbutils('IsLibContext',blkH),return;end

    MIN_NUM_REGS=getMinNumReg();
    MAX_NUM_REGS=getMaxNumReg();
    blkPath=soc.blkcb.cbutils('GetBlkPath',blkH);
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    sysH=bdroot(blkH);

    SetMaskHelp(blkH);

    try
        assert(blkP.NumRegisters>=MIN_NUM_REGS,message('soc:msgs:MinRegistersExceeded',MIN_NUM_REGS));
        assert(blkP.NumRegisters<=MAX_NUM_REGS,message('soc:msgs:MaxRegistersExceeded',MAX_NUM_REGS));

        if blkP.NumRegisters~=length(blkP.RegTableNames)
            msg=message('soc:msgs:MustEditRegTable',blkPath);
            switch get_param(sysH,'SimulationStatus')
            case{'updating','initializing','running'}
                error(msg);
            otherwise
                error(msg);
            end
        end

        numReg=blkP.NumRegisters;
        for r=1:numReg
            hreg=[blkPath,'/Register',num2str(r)];
            switch blkP.RegTableRW{r}
            case{'W','w','Write','write'}
                dir='SW to HW';
            case{'R','r','Read','read'}
                dir='HW to SW';
            otherwise
                error(message('soc:msgs:InternalBadRegAccessType',blkP.RegTableRW{r}));
            end
            set_param(hreg,'Direction',dir);
            set_param(hreg,'DataTypeStr',blkP.RegTableDataTypes{r});
            set_param(hreg,'VectorSize',blkP.RegTableVectorSizes{r});
            switch get_param(sysH,'SimulationStatus')
            case{'updating','initializing','running'}
                set_param(hreg,'SampleTime',mat2str(blkP.SampleTime));
            otherwise
                try
                    set_param(hreg,'SampleTime',mat2str(blkP.SampleTime));
                catch

                end
            end
        end

        for r=numReg+1:MAX_NUM_REGS
            hreg=[blkPath,'/Register',num2str(r)];
            set_param(hreg,'Direction','None');
        end

        update_subsystem_ports(blkH,blkPath,sysH,blkP);
        SetMaskDisplay(blkH,blkP);
        soc.internal.setBlockIcon(blkH,'socicons.RegisterChannel');
    catch ME
        hadError=true;
        rethrow(ME);
    end
end

function AddTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('RegisterTable');
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);

    MAX_NUM_REGS=getMaxNumReg();
    rowIndex=tabC.getNumberOfRows();
    assert(rowIndex<MAX_NUM_REGS,message('soc:msgs:MaxRegistersExceeded',MAX_NUM_REGS));

    rowNum=sprintf('reg%d',rowIndex+1);
    while(~isempty(find(contains(blkP.RegTableNames,rowNum),1)))
        rowIndex=rowIndex+1;
        rowNum=sprintf('reg%d',rowIndex);
    end
    tabR=GetDefaultTableRow(rowNum);
    tabC.addRow(tabR.RegTableNames,tabR.RegTableRW,...
    tabR.RegTableDataTypes,tabR.RegTableVectorSizes);
    SyncTableParams(blkH);
end

function DeleteTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('RegisterTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'descend');

    MIN_NUM_REGS=getMinNumReg();
    assert((tabC.getNumberOfRows()-numRows)>=MIN_NUM_REGS,message('soc:msgs:MinRegistersExceeded',MIN_NUM_REGS));

    for i=1:numRows
        tabC.removeRow(rowIndex(i));
    end
    SyncTableParams(blkH);

end

function ShiftTableRowUpCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('RegisterTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'ascend');

    for i=1:numRows
        if rowIndex(i)==1
            break;
        end
        tabC.swapRows(rowIndex(i)-1,rowIndex(i));
    end
    SyncTableParams(blkH);
end

function ShiftTableRowDownCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('RegisterTable');
    rowIndex=tabC.getSelectedRows();
    numRows=numel(rowIndex);
    rowIndex=sort(rowIndex,'descend');

    for i=1:numRows
        if rowIndex(i)==tabC.getNumberOfRows()
            break;
        end
        tabC.swapRows(rowIndex(i)+1,rowIndex(i));
    end
    SyncTableParams(blkH);
end

function EditTableRowCb(blkH)
    maskObj=Simulink.Mask.get(blkH);
    tableControl=maskObj.getDialogControl('RegisterTable');
    rowIndex=tableControl.getSelectedRows();
    if~isempty(rowIndex)
        d=soc.internal.EditRegisterTableDDG(blkH,rowIndex(1));
        DAStudio.Dialog(d);
    end
end

function SyncTableParams(blkH)

    maskObj=Simulink.Mask.get(blkH);
    tabC=maskObj.getDialogControl('RegisterTable');
    numRows=tabC.getNumberOfRows();
    numCols=tabC.getNumberOfColumns();

    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
    blkP.NumRegisters=numRows;
    pMap=containers.Map((1:numCols),{'RegTableNames','RegTableRW','RegTableDataTypes','RegTableVectorSizes'});
    for i=1:numCols
        col=pMap(i);
        blkP.(col)=[];
        for j=1:numRows
            blkP.(col){j}=tabC.getValue([double(j),double(i)]);
        end
        set_param(blkH,col,['{',sprintf('''%s'' ',blkP.(col){:}),'}']);
    end
    set_param(blkH,'NumRegisters',num2str(blkP.NumRegisters));
    defValues=cell([1,blkP.NumRegisters]);
    defValues(1,:)={'x"0000"'};
    set_param(blkH,'RegTableDefaultValues',['{',sprintf('''%s'' ',defValues{:}),'}']);
    UpdateSampleTimeVisibility(blkH,blkP.RegTableRW);
end

function regTableRow=GetDefaultTableRow(idx)
    regTableRow.RegTableNames=idx;
    regTableRow.RegTableRW='Read';
    regTableRow.RegTableDataTypes='uint32';
    regTableRow.RegTableVectorSizes='1';
end

function UpdateSampleTimeVisibility(blkH,regRW)
    mv=get_param(blkH,'MaskVisibilities');
    if any(contains(regRW,'Write'))
        if isequal(mv{2},'off')
            mv{2}='on';
            set_param(blkH,'MaskVisibilities',mv);
        end
    else
        if isequal(mv{2},'on')
            mv{2}='off';
            set_param(blkH,'MaskVisibilities',mv);
        end
    end
end

function ResetTableCb(blkH)
    maskObj=Simulink.Mask.get(blkH);


    tabC=maskObj.getDialogControl('RegisterTable');
    numCols=tabC.getNumberOfColumns();
    blkP=soc.blkcb.cbutils('GetDialogParams',blkH);
    tabS=[];
    if~isequal({blkP.RegisterTable{:,1}},blkP.RegTableNames)||...
        ~isequal({blkP.RegisterTable{:,2}},blkP.RegTableRW)||...
        ~isequal({blkP.RegisterTable{:,3}},blkP.RegTableDataTypes)||...
        ~isequal({blkP.RegisterTable{:,4}},blkP.RegTableVectorSizes)

        pMap=containers.Map((1:numCols),{'RegTableNames','RegTableRW','RegTableDataTypes','RegTableVectorSizes'});
        for i=1:blkP.NumRegisters

            for j=1:numCols
                col=pMap(j);
                if j==2
                    val=blkP.(col){i};
                    if strcmpi(val,'r')
                        val='Read';
                    elseif strcmpi(val,'w')
                        val='Write';
                    end
                    blkP.(col){i}=val;
                end
                tabR{j}=sprintf('''%s''',blkP.(col){i});%#ok<*AGROW>
            end

            tabR=strjoin(string(tabR),',');
            if isempty(tabS)
                tabS=tabR;
            else
                tabS=strcat(tabS,';',tabR);
            end
        end

        tabC.setData(sprintf("{%s}",tabS));
        UpdateSampleTimeVisibility(blkH,blkP.RegTableRW);
    end
end

function SetMaskHelp(blkH)

    helpTopic='soc_registerchannel';
    fullhelp=sprintf('eval(''soc.internal.helpview(''''%s'''')'')',helpTopic);

    set_param(blkH,'MaskHelp',fullhelp);

end

function SetMaskDisplay(blkH,blkP)




    numReg=blkP.NumRegisters;
    inputLabels=cell(numReg*2,1);
    outputLabels=cell(numReg*2,1);
    pidx=0;
    for r=1:numReg
        pidx=pidx+1;
        inputLabels{pidx}=r;
        outputLabels{pidx}=r;
        pidx=pidx+1;
        inputLabels{pidx}=blkP.RegTableNames{r};
        outputLabels{pidx}=blkP.RegTableNames{r};
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
    MAX_NUM_REGS=getMaxNumReg();
    commonargs={'Regexp','on','LookUnderMasks','all','FollowLinks','on','SearchDepth',1};
    allInPorts=find_system(blkPath,commonargs{:},'BlockType','Inport');
    allInGrounds=find_system(blkPath,commonargs{:},'BlockType','Ground');
    allOutPorts=find_system(blkPath,commonargs{:},'BlockType','Outport');
    allOutTerms=find_system(blkPath,commonargs{:},'BlockType','Terminator');

    interfaceChange=false;
    if blkP.NumRegisters<length(allInPorts)

        interfaceChange=true;
        for pidx=blkP.NumRegisters+1:MAX_NUM_REGS-length(allInGrounds)
            wrname=['wr_reg',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Ground','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','constant'));
            set_param(newwrblk{1},'Name',wrname);
        end
    elseif blkP.NumRegisters>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allInPorts)+1:blkP.NumRegisters
            wrname=['wr_reg',num2str(pidx)];
            newwrblk=replace_block(blkPath,'FollowLinks','On','Name',wrname,'Inport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','inport'));
            set_param(newwrblk{1},'Name',wrname);
        end
    else

    end
    if blkP.NumRegisters<length(allOutPorts)

        interfaceChange=true;
        for pidx=blkP.NumRegisters+1:MAX_NUM_REGS-length(allOutTerms)
            rdname=['rd_reg',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Terminator','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','terminator'));
            set_param(newrdblk{1},'Name',rdname);
        end
    elseif blkP.NumRegisters>length(allInPorts)

        interfaceChange=true;
        for pidx=length(allOutPorts)+1:blkP.NumRegisters
            rdname=['rd_reg',num2str(pidx)];
            newrdblk=replace_block(blkPath,'FollowLinks','On','Name',rdname,'Outport','noprompt');
            assert(~isempty(newwrblk),message('soc:msgs:InternalNoNewBlkFor','outport'));
            set_param(newrdblk{1},'Name',rdname);
        end
    else

    end


    if isequal(get_param(bdroot(blkH),'SimulationStatus'),'stopped')
        s=soc.blkcb.GenPortSchema('Register Channel',blkP.RegTableRW);
        set_param(blkH,'PortSchema',s);
    end

    if interfaceChange



        pos=get_param(blkPath,'Position');
        set_param(blkPath,'Position',pos-[10,10,20,20]);
        set_param(blkPath,'Position',pos);
    end
end

function MAX_NUM_REGS=getMaxNumReg()
    MAX_NUM_REGS=32;
end

function MIN_NUM_REGS=getMinNumReg()
    MIN_NUM_REGS=1;
end


