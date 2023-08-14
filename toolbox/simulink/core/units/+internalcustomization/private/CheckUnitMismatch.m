function CheckUnitMismatch



    mdladvroot=ModelAdvisor.Root;


    unitsMismatchCheck=ModelAdvisor.Check('mathworks.design.UnitMismatches');
    unitsMismatchCheck.Title=DAStudio.message('Simulink:tools:MATitleIdentUnitMismatchPairs');
    unitsMismatchCheck.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentUnitMismatchPairs');
    unitsMismatchCheck.setCallbackFcn(@ExecCheckUnitMismatch,'PostCompile','StyleOne');
    unitsMismatchCheck.CSHParameters.MapKey='ma.simulink';
    unitsMismatchCheck.CSHParameters.TopicID='MATitleIdentUnitMismatchPairs';
    unitsMismatchCheck.Visible=true;
    unitsMismatchCheck.Value=false;
    mdladvroot.publish(unitsMismatchCheck,'Simulink');




    function result=ExecCheckUnitMismatch(system)

        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
        result={};
        modelname=bdroot(system);
        MismatchPairsStruct=cell2mat(Simulink.UnitUtils.getUnitMismatchPairsList(modelname));
        MismatchPairsBusStruct=cell2mat(Simulink.UnitUtils.getUnitMismatchBusPairsList(modelname));
        Mismatch_BusObj_Pairs_Report=cell2mat(Simulink.UnitUtils.getUnitMismatchBusObjPairsList(modelname));
        UnsuccessfulAutoConv=cell2mat(Simulink.UnitUtils.getUnsuccessfulAutomaticUnitConversionsList(modelname));
        MismatchPairsLoadingStruct=cell2mat(Simulink.UnitUtils.getUnitMismatchesWithLoadedDataList(modelname));
        subsyspath=[system,'/'];

        if(strcmp(modelname,system))
            Mismatch_Pairs_Report=MismatchPairsStruct;
            Mismatch_Bus_Pairs_Report=MismatchPairsBusStruct;
            Unsuccessful_AutoConv_Report=UnsuccessfulAutoConv;
            Mismatch_Loading_Pairs_Report=MismatchPairsLoadingStruct;
        else


            if(~isempty(MismatchPairsStruct))
                srcblkpaths={MismatchPairsStruct(:).SrcBlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                StructIdx_src=find(~cellfun(@isempty,srcinsubsys));
                dstblkpaths={MismatchPairsStruct(:).DstBlockPath};
                dstinsubsys=strfind(dstblkpaths,subsyspath);
                StructIdx_dst=find(~cellfun(@isempty,dstinsubsys));
                SubStructIdx=union(StructIdx_src,StructIdx_dst);
                Mismatch_Pairs_Report=MismatchPairsStruct(SubStructIdx,1);
            else
                Mismatch_Pairs_Report=MismatchPairsStruct;
            end

            if(~isempty(MismatchPairsBusStruct))
                subsyspath=[system,'/'];
                srcblkpaths={MismatchPairsBusStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Mismatch_Bus_Pairs_Report=MismatchPairsBusStruct(SubStructIdx,1);
            else
                Mismatch_Bus_Pairs_Report=MismatchPairsBusStruct;
            end

            if(~isempty(UnsuccessfulAutoConv))
                blockPaths={UnsuccessfulAutoConv(:).InsertedAttemptedAtBlockPath};
                blockPathsInSubsys=strfind(blockPaths,subsyspath);
                StructIdx_blk=find(~cellfun(@isempty,blockPathsInSubsys));
                Unsuccessful_AutoConv_Report=UnsuccessfulAutoConv(StructIdx_blk,1);
            else
                Unsuccessful_AutoConv_Report=UnsuccessfulAutoConv;
            end

            if(~isempty(MismatchPairsLoadingStruct))
                srcblkpaths={MismatchPairsLoadingStruct(:).BlockPath};
                srcinsubsys=strfind(srcblkpaths,subsyspath);
                SubStructIdx=find(~cellfun(@isempty,srcinsubsys));
                Mismatch_Loading_Pairs_Report=MismatchPairsLoadingStruct(SubStructIdx,1);
            else
                Mismatch_Loading_Pairs_Report=MismatchPairsLoadingStruct;
            end
        end

        ft1=ModelAdvisor.FormatTemplate('ListTemplate');
        ft1.setInformation(DAStudio.message('Simulink:tools:MAInfoIdentUnitMismatchPairs'));

        if(~isempty(Mismatch_Pairs_Report)||~isempty(Mismatch_Bus_Pairs_Report)||~isempty(Mismatch_BusObj_Pairs_Report)||~isempty(Unsuccessful_AutoConv_Report)||~isempty(Mismatch_Loading_Pairs_Report))

            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setCheckErrorSeverity(1);


            setSubResultStatus(ft1,'Fail');
            numMismatches=length(Mismatch_Pairs_Report)+length(Mismatch_Bus_Pairs_Report)+...
            length(Mismatch_BusObj_Pairs_Report)+...
            length(Unsuccessful_AutoConv_Report)+...
            length(Mismatch_Loading_Pairs_Report);

            if(numMismatches==1)
                setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAFailIdentUnitMismatchPairsSingular'));
            else
                setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAFailIdentUnitMismatchPairs',numMismatches));
            end

            ft1.setSubBar(0);
            result{end+1}=ft1;

            if(~isempty(Mismatch_Pairs_Report))
                table1=ModelAdvisor.FormatTemplate('TableTemplate');
                table1.setSubBar(0);
                table1.setTableTitle(DAStudio.message('Simulink:tools:MADetailUnitMismatchPairs'));
                table1.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MAcol1UnitMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol2UnitMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsSrcUnits'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDstUnits'),...
                DAStudio.message('Simulink:tools:MAcol5UnitMismatchPairs')});

                tableInfo1={};


                for r=1:length(Mismatch_Pairs_Report)

                    srcport=Mismatch_Pairs_Report(r,1).SrcPortIdx;
                    srcblkpathHTMLStr=convert2HTMLStr(Mismatch_Pairs_Report(r,1).SrcBlockPath);
                    outportstr=DAStudio.message('Simulink:tools:MAUnitInconsOutPortStr');
                    msg1=ModelAdvisor.Text([outportstr,' ',num2str(srcport),' ']);
                    msg2=ModelAdvisor.Text(srcblkpathHTMLStr);
                    srclink=[msg1,msg2];

                    dstport=Mismatch_Pairs_Report(r,1).DstPortIdx;
                    dstblkpathHTMLStr=convert2HTMLStr(Mismatch_Pairs_Report(r,1).DstBlockPath);
                    inportstr=DAStudio.message('Simulink:tools:MAUnitInconsInPortStr');
                    msg1=ModelAdvisor.Text([inportstr,' ',num2str(dstport),' ']);
                    msg2=ModelAdvisor.Text(dstblkpathHTMLStr);
                    dstlink=[msg1,msg2];

                    srcunits=Mismatch_Pairs_Report(r,1).SrcUnitInfo;

                    dstunits=Mismatch_Pairs_Report(r,1).DstUnitInfo;

                    mismatch_type=Mismatch_Pairs_Report(r,1).ErrorCause;

                    tableInfo1=[tableInfo1;{num2str(r),srclink,dstlink,srcunits,dstunits,mismatch_type}];%#ok
                end

                table1.setTableInfo(tableInfo1);
                result{end+1}=table1;

            end

            if(~isempty(Mismatch_Bus_Pairs_Report))
                table2=ModelAdvisor.FormatTemplate('TableTemplate');
                table2.setSubBar(0);
                table2.setTableTitle(DAStudio.message('Simulink:tools:MADetailUnitMismatchBus'));
                table2.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MAcol1UnitBusMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol2UnitBusMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol3UnitBusMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDst1Units'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDst2Units'),...
                DAStudio.message('Simulink:tools:MAcol5UnitMismatchPairs')});
                tableInfo2={};


                for r=1:length(Mismatch_Bus_Pairs_Report)

                    srcblkpath=Mismatch_Bus_Pairs_Report(r,1).BlockPath;
                    srclink=srcblkpath;

                    inportstr=DAStudio.message('Simulink:tools:MAUnitInconsInPortStr');
                    dst1port=Mismatch_Bus_Pairs_Report(r,1).Dst1PortIdx;
                    dst1blkpath=Mismatch_Bus_Pairs_Report(r,1).Dst1Name;
                    if isempty(dst1blkpath)
                        dst1link=ModelAdvisor.Text('');
                    elseif dst1port==0
                        dst1link=ModelAdvisor.Text(dst1blkpath);
                    else
                        msg1=ModelAdvisor.Text([inportstr,' ',num2str(dst1port),' ']);
                        msg2=ModelAdvisor.Text(dst1blkpath);
                        dst1link=[msg1,msg2];
                    end

                    outportstr=DAStudio.message('Simulink:tools:MAUnitInconsOutPortStr');
                    dst2port=Mismatch_Bus_Pairs_Report(r,1).Dst2PortIdx;
                    dst2blkpath=Mismatch_Bus_Pairs_Report(r,1).Dst2Name;
                    dst2isinputport=Mismatch_Bus_Pairs_Report(r,1).Dst2IsInputPort;
                    if isempty(dst2blkpath)
                        dst2link=ModelAdvisor.Text('');
                    elseif dst2port==0
                        dst2link=ModelAdvisor.Text(dst2blkpath);
                    elseif dst2isinputport
                        msg1=ModelAdvisor.Text([inportstr,' ',num2str(dst2port),' ']);
                        msg2=ModelAdvisor.Text(dst2blkpath);
                        dst2link=[msg1,msg2];
                    else
                        msg1=ModelAdvisor.Text([outportstr,' ',num2str(dst2port),' ']);
                        msg2=ModelAdvisor.Text(dst2blkpath);
                        dst2link=[msg1,msg2];
                    end

                    dst1units=Mismatch_Bus_Pairs_Report(r,1).Dst1UnitInfo;

                    dst2units=Mismatch_Bus_Pairs_Report(r,1).Dst2UnitInfo;

                    mismatch_type=Mismatch_Bus_Pairs_Report(r,1).ErrorCause;

                    tableInfo2=[tableInfo2;{num2str(r),srclink,dst1link,dst2link,dst1units,dst2units,mismatch_type}];%#ok
                end

                table2.setTableInfo(tableInfo2);
                result{end+1}=table2;

            end

            if(~isempty(Mismatch_BusObj_Pairs_Report))
                table3=ModelAdvisor.FormatTemplate('TableTemplate');
                table3.setSubBar(0);
                table3.setTableTitle(DAStudio.message('Simulink:tools:MADetailUnitMismatchBusObj'));
                table3.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MAcol1UnitBusObjMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol2UnitBusObjMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol3UnitBusObjMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsBusObjUnits'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDstUnits'),...
                DAStudio.message('Simulink:tools:MAcol5UnitMismatchPairs')});
                tableInfo3={};


                for r=1:length(Mismatch_BusObj_Pairs_Report)

                    srcblkpath=Mismatch_BusObj_Pairs_Report(r,1).BlockPath;
                    srclink=ModelAdvisor.Text(srcblkpath);

                    buselem=Mismatch_BusObj_Pairs_Report(r,1).ElemName;

                    busobj=Mismatch_BusObj_Pairs_Report(r,1).BusObjName;
                    busobjlink=sprintf('<a href = "matlab:Simulink.UnitUtils.openObjectEditor(''%s'', ''%s'')">%s</a>',modelname,busobj,busobj);

                    objunits=Mismatch_BusObj_Pairs_Report(r,1).ObjUnitInfo;

                    dstunits=Mismatch_BusObj_Pairs_Report(r,1).DstUnitInfo;

                    mismatch_type=Mismatch_BusObj_Pairs_Report(r,1).ErrorCause;

                    tableInfo3=[tableInfo3;{num2str(r),srclink,buselem,busobjlink,objunits,dstunits,mismatch_type}];%#ok
                end

                table3.setTableInfo(tableInfo3);
                result{end+1}=table3;

            end

            if(~isempty(Unsuccessful_AutoConv_Report))
                table4=ModelAdvisor.FormatTemplate('TableTemplate');
                table4.setSubBar(0);
                table4.setTableTitle(DAStudio.message('Simulink:tools:MADetailUnitAutoConvUnsuccessful'));
                table4.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MACol1UnitAutoConvUnsuccessful'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsSrcUnits'),...
                DAStudio.message('Simulink:tools:MAUnitsInconsDstUnits'),...
                DAStudio.message('Simulink:tools:MACol1UnitAutoConvUnsuccessfulReason')});

                tableInfo4={};


                ImplConverCell=struct2cell(Unsuccessful_AutoConv_Report);

                for r=1:length(Unsuccessful_AutoConv_Report)

                    srcport=cell2mat(ImplConverCell(1,r));
                    srcblkpathHTMLStr=convert2HTMLStr(ImplConverCell{2,r});
                    portstr=DAStudio.message('Simulink:tools:MAUnitInconsInPortStr');
                    msg1=ModelAdvisor.Text([portstr,' ',num2str(srcport),' ']);
                    msg2=ModelAdvisor.Text(srcblkpathHTMLStr);
                    srclink=[msg1,msg2];

                    srcunits=cell2mat(ImplConverCell(3,r));

                    dstunits=cell2mat(ImplConverCell(4,r));

                    reason=cell2mat(ImplConverCell(5,r));

                    tableInfo4=[tableInfo4;{num2str(r),srclink,srcunits,dstunits,reason}];%#ok

                end

                table4.setTableInfo(tableInfo4);
                result{end+1}=table4;

            end

            if(~isempty(Mismatch_Loading_Pairs_Report))
                table5=ModelAdvisor.FormatTemplate('TableTemplate');
                table5.setSubBar(0);
                table5.setTableTitle(DAStudio.message('Simulink:tools:MADetailUnitMismatchLoading'));
                table5.setColTitles({' ',...
                DAStudio.message('Simulink:tools:MAcol1UnitLoadingMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol2UnitLoadingMismatchPairs'),...
                DAStudio.message('Simulink:tools:MAcol3UnitLoadingMismatchPairs')});
                tableInfo5={};


                for r=1:length(Mismatch_Loading_Pairs_Report)
                    srcblkpath=Mismatch_Loading_Pairs_Report(r,1).PortBlockPath;
                    prefixpath='';
                    if(Mismatch_Loading_Pairs_Report(r,1).IsBus)
                        prefixpath=DAStudio.message('Simulink:Unit:BusObjLoading');
                    end
                    msg1=ModelAdvisor.Text([prefixpath,' ']);
                    msg2=ModelAdvisor.Text(srcblkpath);
                    srclink=[msg1,msg2];

                    portunit=Mismatch_Loading_Pairs_Report(r,1).PortUnitInfo;

                    dataunit=Mismatch_Loading_Pairs_Report(r,1).DataUnitInfo;

                    tableInfo5=[tableInfo5,{num2str(r),srclink,portunit,dataunit}];%#ok
                end

                table5.setTableInfo(tableInfo5);
                result{end+1}=table5;
            end
        else

            setSubResultStatus(ft1,'Pass');
            setSubResultStatusText(ft1,DAStudio.message('Simulink:tools:MAPassIdentUnitMismatchPairs'));
            mdladvObj.setCheckResultStatus(true);
            ft1.setSubBar(0);
            result{end+1}=ft1;

        end
