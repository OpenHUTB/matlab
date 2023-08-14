function blockDiags=generateDiagnostics(mdl,J,mdlHierInfo)







    handles=J.Mi.BlockHandles;


    if isfield(J.Mi,'Replacements')
        replacements={J.Mi.Replacements.Name}.';
    else
        replacements={};
    end



    reph=cell2mat(get_param(replacements,'handle'));
    handles=union(handles,reph,'stable');
    numBlocks=numel(handles);


    blockDiags=linearize.advisor.BlockDiagnostic.empty;




    expbusblks={};
    for blkIdx=1:numBlocks
        handle=handles(blkIdx);
        bObj=get_param(handle,'Object');


        if bObj.isSynthesized&&...
            (~strcmp(bObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')||...
            strcmp(get_param(bObj.getTrueOriginalBlock,'BlockType'),'BusCreator'))
            if LocalIsBlockExpanded(bObj)
                ebusblk=getfullname(get_param(handle,'Parent'));
                if~ismember(ebusblk,expbusblks)
                    expbusblks{end+1}=ebusblk;%#ok<AGROW>
                end
            end
        else

            blockDiags=LocalProcessBlockDiagnostics(mdl,blockDiags,...
            blkIdx,J,replacements,mdlHierInfo,bObj);
        end
    end


    blockDiags=LocalGenerateNetDiagnostics(mdl,blockDiags,J,mdlHierInfo);




    function bdiags=LocalGenerateNetDiagnostics(mdl,bdiags,J,mdlHierInfo)






        slvrblks=find_system(mdl,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'MaskType',sprintf('Solver\nConfiguration'));
        jhandles=J.Mi.BlockHandles;
        diaghandles=getJacobianBlockHandle(bdiags);
        diags2add=linearize.advisor.BlockDiagnostic.empty;
        diags2rm=[];
        for i=1:numel(slvrblks)
            slvrblk=get_param(slvrblks{i},'handle');




            children=jhandles(contains(getfullname(jhandles),[getfullname(slvrblk),'/']));

            if any(contains(getfullname(children),'/RTP'))
                rtpblkhandles=jhandles(contains(getfullname(jhandles),'Subsystem_around_RTP'));


                for idx=1:length(rtpblkhandles)
                    rtpblkobj=get_param(rtpblkhandles(idx),'Object');
                    if rtpblkobj.isSynthesized

                        children=[children;rtpblkhandles(idx)];%#ok<AGROW> 
                    end
                end
            end
            engineidx=ismember(diaghandles,children);

            opt=linearizeOptions();
            [sys,info]=linearize.jacobian.subsystemFold(J,children,opt,-1);

            [blockPath,graphicalParentBlockHandles,isMultiInstanced]=...
            linearize.advisor.utils.getBlockPathInfo(mdl,slvrblk,mdlHierInfo);

            gpath=linearize.advisor.utils.getBlockPathInfo(mdl,slvrblk,mdlHierInfo);

            enginediags=bdiags(engineidx);


            nx=size(sys.A,1);
            offsets=info.Offsets;


            if isfield(offsets,'x')&&nx>0
                cname=sys.StateName;
                cx=num2cell(offsets.x);
                xop(nx)=struct('Name',[],'x',[]);%#ok<AGROW>
                [xop.Name]=cname{:};
                [xop.x]=cx{:};
            else
                xop=struct('Name',{},'x',{});
            end

            pred=info.Predecessors;
            preduports=info.PredecessorsRootInputs;
            nu=size(sys.D,2);
            cports=num2cell(1:nu);
            cu=num2cell(full([J.Mi.Offsets.allBlocksOut(pred);J.Mi.Offsets.allBlocksIn(preduports)]));
            if nu>0
                uop(nu)=struct('Port',[],'u',[]);%#ok<AGROW>
                [uop.Port]=cports{:};
                [uop.u]=cu{:};
            else
                uop=struct('Port',{},'u',{});
            end


            if~isempty(xop)
                xnames={xop.Name}';
                needschange=find(~cellfun(@isempty,regexp(xnames,'^x\d*$')));
                for j=1:numel(needschange)
                    xnames{needschange(j)}=sprintf('x%u',j);
                end
                [xop.Name]=xnames{:};
            end

            op=linearize.advisor.BlockOperatingPoint(...
            slvrblk,...
            blockPath,...
            graphicalParentBlockHandles,...
            xop,uop);
            clear('xop','uop');


            lindata.A=sys.A;
            lindata.B=sys.B;
            lindata.C=sys.C;
            lindata.D=sys.D;
            lindata.Ts=sys.Ts;
            lindata.StateName=sys.StateName;
            lindata.Replacement=[];
            lindata.Name=regexprep(get_param(slvrblk,'Name'),'\n',' ');

            blkData=struct('BlockHandle',slvrblk,...
            'LinType',ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeSimscapeNetwork'),...
            'LinData',lindata,...
            'StructurallyOnPath',false,...
            'NumericallyOnPath',false,...
            'IsSpecified',false,...
            'OperatingPoint',op,...
            'EngineMessages','',...
            'IsMultiInstanced',isMultiInstanced,...
            'GraphicalBlockPath',gpath,...
            'GraphicalParentBlockHandles',graphicalParentBlockHandles);

            bdiag=linearize.advisor.SimscapeNetDiagnostic(blkData,enginediags);

            if~isempty(bdiag)
                diags2add(end+1)=bdiag;%#ok<AGROW>

                diags2rm=union(diags2rm,find(engineidx));
            end
        end

        bdiags(diags2rm)=[];

        bdiags=[bdiags,diags2add];

        function val=LocalIsBlockExpanded(bObj)

            val=false;
            if strcmp(bObj.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')&&...
                ~strcmp(bObj.BlockType,'SignalConversion')
                val=true;
            end

            function bdiags=LocalProcessBlockDiagnostics(mdl,bdiags,blkIdx,J,replacements,mdlHierInfo,bObj)

                blockType=bObj.BlockType;
                pObj=getParent(bObj);

                if~(isa(pObj,'Simulink.SubSystem')&&...
                    strcmp(pObj.MaskType,'Time Operating Condition Snapshot'))
                    switch blockType
                    case{'SimscapeBlock','SimscapeComponentBlock','SimscapeMultibodyBlock','PMIOPort'}




                    case{'SimscapeInputBlock','SimscapeExecutionBlock'}
                        if linearize.advisor.utils.isSimscapeStateBlock(bObj.Handle)
                            bdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,'SimscapeState');
                        else
                            bdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,'SimscapeExecution');
                        end
                        if~isempty(bdiag)
                            bdiags(end+1)=bdiag;
                        end
                    case{'ModelReference'}
                        mrefdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,'ModelReference');
                        if~isempty(mrefdiag)
                            bdiags(end+1)=mrefdiag;
                        end
                    case{'SubSystem'}
                        ssdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,'Subsystem');
                        if~isempty(ssdiag)
                            bdiags(end+1)=ssdiag;
                        end
                    otherwise
                        bdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,'Block');
                        if~isempty(bdiag)
                            bdiags(end+1)=bdiag;
                        end
                    end
                end

                function bdiag=LocalCreateBlockDiagnostic(mdl,bObj,blkIdx,J,replacements,mdlHierInfo,type)

                    handle=bObj.Handle;
                    block=getfullname(getTrueOriginalBlock(bObj));

                    [lindata,isReplaced]=LocalGetBlockSysWithReplacements(...
                    block,blkIdx,J,replacements);

                    lintype=LocalGetLinType(blkIdx,J,isReplaced);
                    types2ignore={...
                    ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeNA')...
                    };

                    if any(strcmp(lintype,types2ignore))
                        bdiag=[];
                    else
                        engmsgs=LocalGetEngineMessages(blkIdx,J,isReplaced);
                        [blockPath,graphicalParentBlockHandles,isMultiInstanced]=...
                        linearize.advisor.utils.getBlockPathInfo(mdl,handle,mdlHierInfo);
                        [xop,uop]=LocalGetBlockOp(blockPath,blkIdx,J,isReplaced,lindata);

                        blkop=linearize.advisor.BlockOperatingPoint(...
                        handle,blockPath,graphicalParentBlockHandles,xop,uop);

                        origpath=getfullname(getTrueOriginalBlock(bObj));
                        gpath=linearize.advisor.utils.getBlockPathInfo(mdl,get_param(origpath,'handle'),mdlHierInfo);

                        blkData=struct('BlockHandle',handle,...
                        'LinType',lintype,...
                        'LinData',lindata,...
                        'StructurallyOnPath',false,...
                        'NumericallyOnPath',false,...
                        'IsSpecified',isReplaced,...
                        'OperatingPoint',blkop,...
                        'EngineMessages',engmsgs,...
                        'IsMultiInstanced',isMultiInstanced,...
                        'GraphicalBlockPath',gpath,...
                        'GraphicalParentBlockHandles',graphicalParentBlockHandles);
                        switch type
                        case 'ModelReference'


                            isNotNormal=~strcmp('Normal',get_param(blockPath,'SimulationMode'));
                            if isReplaced||isNotNormal
                                bdiag=linearize.advisor.BlockDiagnostic(blkData);
                            else
                                bdiag=[];
                            end
                        case 'Subsystem'


                            if isReplaced
                                bdiag=linearize.advisor.BlockDiagnostic(blkData);
                            else
                                bdiag=[];
                            end
                        case 'SimscapeState'
                            if isfield(J.Mi.BlockAnalyticFlags(blkIdx).jacobian,'data')
                                nga=J.Mi.BlockAnalyticFlags(blkIdx).jacobian.data.NGA;
                                netlin=J.Mi.BlockAnalyticFlags(blkIdx).jacobian.data.NetLin;
                                [xop,uop]=getNetworkOperatingPoint(nga);
                                netop=linearize.advisor.BlockOperatingPoint(handle,...
                                blockPath,graphicalParentBlockHandles,xop,uop);
                                blkData.OperatingPoint=netop;
                                blkData.LinType=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeSimscapeNetwork');
                                bdiag=linearize.advisor.SimscapeNetworkDiagnostic(blkData,nga);
                            else
                                bdiag=linearize.advisor.BlockDiagnostic(blkData);
                            end
                        otherwise
                            bdiag=linearize.advisor.BlockDiagnostic(blkData);
                        end
                    end

                    function[xop,uop]=LocalGetBlockOp(blockPath,blockCount,J,isReplaced,lindata)


                        xop=struct('Name',{},'x',{});
                        uop=struct('Port',{},'u',{});



                        if isReplaced
                            nx=order(lindata.Replacement);
                            for i=1:nx
                                xop(i).Name=sprintf('x%u',i);
                                xop(i).x=0;
                            end


                            blkhandles=J.Mi.BlockHandles;
                            rmdataIdx=strcmp(getfullname([J.Mi.BlockRemovalData.Block]'),blockPath);
                            if any(rmdataIdx)
                                rmdata=J.Mi.BlockRemovalData(rmdataIdx);
                                inputHandles=unique(rmdata.InputHandles,'stable');
                                for i=1:numel(inputHandles)
                                    uh=inputHandles(i);
                                    uhidx=find(blkhandles==uh);
                                    uIdx=J.Mi.InputIdx(uhidx):J.Mi.InputIdx(uhidx+1)-1;

                                    if~isempty(uIdx)
                                        ports=J.Mi.InputInfo(uIdx,3);
                                        maxport=max(ports);
                                        for j=1:maxport
                                            pIdx=j==ports;
                                            u=full(J.Mi.Offsets.allBlocksIn(uIdx(pIdx)));
                                            uop(i+j-1).Port=i+j-1;
                                            uop(i+j-1).u=u;
                                        end
                                    end
                                end
                            end
                        else
                            uIdx=J.Mi.InputIdx(blockCount):J.Mi.InputIdx(blockCount+1)-1;
                            xIdx=J.Mi.StateIdx(blockCount):J.Mi.StateIdx(blockCount+1)-1;


                            if~isempty(xIdx)&&isfield(J.Mi.Offsets,'x')
                                xnames=J.stateName(xIdx);
                                ct=1;
                                for i=1:numel(xnames)
                                    if isempty(xnames{i})
                                        xnames{i}=sprintf('x%u',ct);
                                        ct=ct+1;
                                    end
                                end
                                xnames=unique(xnames,'stable');
                                x=J.Mi.Offsets.x(xIdx);
                                if numel(xnames)~=numel(x)
                                    xop(1).Name=xnames{1};
                                    xop(1).x=x;
                                else
                                    for i=1:numel(xnames)
                                        xop(i).Name=xnames{i};
                                        xop(i).x=x(i);
                                    end
                                end
                            end

                            if~isempty(uIdx)
                                ports=J.Mi.InputInfo(uIdx,3);
                                maxport=max(ports);
                                for i=1:maxport
                                    pIdx=i==ports;
                                    u=full(J.Mi.Offsets.allBlocksIn(uIdx(pIdx)));
                                    uop(i).Port=i;
                                    uop(i).u=u;
                                end
                            end
                        end

                        function[lindata,isReplaced]=LocalGetBlockSysWithReplacements(block,blockCount,J,replacements)


                            blkname=regexprep(get_param(block,'Name'),'\n',' ');
                            [isReplaced,repIdx]=ismember(block,replacements);
                            if isReplaced
                                repVal=J.Mi.Replacements(repIdx).Value;
                                if isa(repVal,'ss')
                                    sys=repVal;
                                elseif isnumeric(repVal)
                                    sys=ss([],[],[],repVal);
                                else
                                    sys=ss(repVal);
                                end
                                lindata.A=[];
                                lindata.B=[];
                                lindata.C=[];
                                lindata.D=[];
                                lindata.Ts=[];
                                lindata.StateName={};
                                lindata.Replacement=sys;
                                lindata.Name=blkname;
                            else
                                lindata=LocalGetBlockSys(blockCount,J,blkname);
                            end

                            function lindata=LocalGetBlockSys(blockCount,J,blkname)

                                yIdx=J.Mi.OutputIdx(blockCount):J.Mi.OutputIdx(blockCount+1)-1;
                                uIdx=J.Mi.InputIdx(blockCount):J.Mi.InputIdx(blockCount+1)-1;
                                xIdx=J.Mi.StateIdx(blockCount):J.Mi.StateIdx(blockCount+1)-1;

                                A=full(J.A(xIdx,xIdx));
                                B=full(J.B(xIdx,uIdx));
                                C=full(J.C(yIdx,xIdx));
                                D=full(J.D(yIdx,uIdx));
                                if isempty(A)
                                    Ts=0;
                                else
                                    Ts=J.Tsx(xIdx(1));


                                    if isinf(Ts)
                                        Ts=0;
                                    end
                                end

                                lindata.A=A;
                                lindata.B=B;
                                lindata.C=C;
                                lindata.D=D;
                                lindata.Ts=Ts;
                                lindata.StateName=J.stateName(xIdx);
                                lindata.Replacement=[];
                                lindata.Name=blkname;

                                function engmsgs=LocalGetEngineMessages(blockCount,J,isReplaced)

                                    if isReplaced


                                        engmsgs='';
                                    else
                                        engmsgs=J.Mi.BlockAnalyticFlags(blockCount).jacobian.message;
                                    end

                                    function lintype=LocalGetLinType(blockCount,J,isSpecified)

                                        if isSpecified
                                            lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeBlockSubstituted');
                                        else
                                            lintype=J.Mi.BlockAnalyticFlags(blockCount).jacobian.type;
                                            switch lintype
                                            case 'exact'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeExact');
                                            case 'perturbation'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypePerturbation');
                                            case 'customized'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeExact');
                                            case 'notApplicable'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeNA');
                                            case 'unknown'
                                                switch get_param(J.Mi.BlockHandles(blockCount),'BlockType')
                                                case{'SimscapeInputBlock','SimscapeExecutionBlock'}
                                                    lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeSimscapeEngine');
                                                otherwise
                                                    lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeUnknown');
                                                end
                                            case 'warning'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypePerturbation');
                                            case 'notSupported'
                                                lintype=ctrlMsgUtils.message('Slcontrol:linadvisor:LinTypeNotSupported');
                                            otherwise
                                                ctrlMsgUtils.error('Slcontrol:linadvisor:InvalidLinType',lintype);
                                            end
                                        end
