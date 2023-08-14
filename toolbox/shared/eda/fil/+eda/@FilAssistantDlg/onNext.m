function onNext(this,dlg)



    closeDialog=false;

    try
        this.Status='';
        this.lastErrorID='';
        this.lastWarningID='';

        onCleanupObj=this.disableWidgets(dlg);

        switch(this.StepID)
        case 1
            this.BuildInfo.Tool=this.BuildInfo.ToolList{this.Tool+1};
            if strcmp(this.BuildInfo.Tool,'MATLAB System Object')
                this.buildOptions={'QuestionDialog','on','BuildOutput','AllML'};
            else
                this.buildOptions={'QuestionDialog','on','BuildOutput','AllSL'};
            end

            if strcmp(this.Board,'Choose a board')
                error('No board was selected. Select a board from the "Board Name" list.');
            end



            this.BuildInfo.FPGASystemClockFrequency=[this.FPGASystemClockFrequency,'MHz'];

            for m=1:4
                tag=['edaIpAddrByte',num2str(m)];
                try
                    byte=eval(['this.IpAddrByte',num2str(m)]);
                    this.BuildInfo.validateIPByte(byte);
                catch ME
                    dlg.setFocus(tag);
                    rethrow(ME);
                end
            end
            this.BuildInfo.IPAddress=sprintf('%s.%s.%s.%s',...
            this.IpAddrByte1,this.IpAddrByte2,this.IpAddrByte3,this.IpAddrByte4);


            for m=1:6
                tag=['edaMacAddrByte',num2str(m)];
                try
                    byte=eval(['this.MacAddrByte',num2str(m)]);
                    this.BuildInfo.validateMACByte(byte);
                catch ME
                    dlg.setFocus(tag);
                    rethrow(ME);
                end
            end
            this.BuildInfo.MACAddress=sprintf('%s-%s-%s-%s-%s-%s',...
            this.MacAddrByte1,this.MacAddrByte2,this.MacAddrByte3,...
            this.MacAddrByte4,this.MacAddrByte5,this.MacAddrByte6);

            [nRow,~]=size(this.FileTableData);
            fileEntries=this.BuildInfo.getFileTypes;
            for m=1:nRow
                this.FileTableData{m,2}.Entries=fileEntries;
                this.FileTableData{m,2}.Value=this.fileTypeStr2Int(this.BuildInfo.SourceFiles.FileType{m})-1;
            end


            setpref('FILSetup','PreferedFPGABoard',this.Board);
            hManager=eda.internal.boardmanager.BoardManager.getInstance;
            ConnectionsAvailable=hManager.getBoardObj(this.Board).getFILConnectionOptions;
            setpref('FILSetup','PreferedFILInterface',ConnectionsAvailable{this.ConnectionSelection+1}.Name);
            [Byte1,leftover]=strtok(this.BuildInfo.IPAddress,'.');
            [Byte2,leftover]=strtok(leftover(2:end),'.');
            [Byte3,leftover]=strtok(leftover(2:end),'.');
            Byte4=strtok(leftover(2:end));
            setpref('FILSetup','PreferedFPGA_IP',{Byte1,...
            Byte2,...
            Byte3,...
            Byte4});

            this.StepID=2;
        case 2

            this.BuildInfo.validateSourceFiles;



            if(this.BuildInfo.TopLevelIndex<0)
                VhdlFileIndicator=strcmpi(this.BuildInfo.SourceFiles.FileType,'VHDL');
                VlogFileIndicator=strcmpi(this.BuildInfo.SourceFiles.FileType,'Verilog');
                HdlFileIndicator=VhdlFileIndicator+VlogFileIndicator;
                numHdlFiles=sum(HdlFileIndicator);
                firstHdlFileIndx=find(HdlFileIndicator,1);

                if(numHdlFiles==1)
                    this.BuildInfo.setTopLevelSourceFile(firstHdlFileIndx);
                    this.FileTableData{firstHdlFileIndx,3}.Value=true;










                end
            end

            assert(this.BuildInfo.TopLevelIndex>0,...
            'EDALink:onNext:NoTopLevelFile',...
            'Top-level file was not selected.');


            this.TopModuleName=strtrim(this.TopModuleName);



            try
                this.BuildInfo.DUTName=this.TopModuleName;
            catch ME
                dlg.setFocus('edaTopModule');
                rethrow(ME);
            end

            if(this.PortEditOption==0)




                generateNewPortTable(this,dlg);

                [oldPortNum,~]=size(this.PortTableData);



                if(oldPortNum==0)||(~l_eqPortTableData(this))
                    this.PortTableData=this.NewPortTableData;
                    if(oldPortNum~=0)
                        this.Status=[this.Status,sprintf('The DUT I/O ports table has been re-generated since the previously created table was out-of-date. Make sure the port types are correct.\n')];
                    end

                end
            else
                this.Status=sprintf('The DUT I/O ports table was not updated automatically since you have selected ''Manually enter I/O port information''.\n');
            end



            this.StepID=3;
        case 3
            if(this.PortEditOption==0)
                assert(this.HasParsingError==false,...
                'EDALink:onNext:ParsingError',...
                this.getCatalogMsgStr('HasParsingErr_Msg'));
            end


            if~strcmpi(this.BuildInfo.HDLSourceType,'SLHDLCoder')
                this.BuildInfo.initializeDUTPorts;
                [numPorts,~]=size(this.PortTableData);
                for m=1:numPorts
                    try
                        portName=this.PortTableData{m,1};
                        this.BuildInfo.validateDUTPortName(portName);
                    catch ME
                        dlg.setFocus('edaPortTable');
                        dlg.selectTableItem('edaPortTable',m-1,0);
                        rethrow(ME);
                    end
                    portDirection=dlg.getTableItemValue('edaPortTable',m-1,1);
                    try
                        portBidwidthStr=dlg.getTableItemValue('edaPortTable',m-1,2);
                        portBitwidth=str2num(portBidwidthStr);%#ok<ST2NM>
                        this.BuildInfo.validateDUTPortWidth(portBitwidth);
                    catch ME
                        dlg.setFocus('edaPortTable');
                        dlg.selectTableItem('edaPortTable',m-1,2);
                        rethrow(ME);
                    end
                    portType=dlg.getTableItemValue('edaPortTable',m-1,3);
                    this.BuildInfo.addDUTPort(portName,portDirection,portBitwidth,portType);
                end
                this.BuildInfo.ResetAssertedLevel=this.ResetAssertLevel;
                this.BuildInfo.ClockEnableAssertedLevel=this.ClockEnableAssertLevel;

                this.BuildInfo.validateDUTPorts;


                generateNewOutputDataTypeTable(this,dlg);
                [oldOutputNum,~]=size(this.OutputDataTypeTableData);


                if(oldOutputNum==0)||(~l_eqOutputDataTypeTableData(this))
                    this.OutputDataTypeTableData=this.NewOutputDataTypeTableData;
                    if(oldOutputNum~=0)
                        this.Status=[this.Status,sprintf('The Output Data Type table has been re-generated since the previously created table was out-of-date. Make sure the data types are correct.\n')];
                    end

                end

            end

            this.StepID=4;
        case 4
            [numOutput,~]=size(this.OutputDataTypeTableData);
            this.BuildInfo.initializeOutputDataTypes;
            for row=1:numOutput
                try
                    if strcmp(this.OutputDataTypeTableData{row,3}.Entries{this.OutputDataTypeTableData{row,3}.Value+1},'Fixedpoint')
                        fracLenStr=this.OutputDataTypeTableData{row,5}.Value;
                        fracLen=str2num(fracLenStr);%#ok<ST2NM>
                        this.BuildInfo.validateOutputDataTypeFracLen(fracLen);
                    else
                        fracLen=0;
                    end
                catch ME
                    dlg.setFocus('edaOutputDataTypeTable');
                    dlg.selectTableItem('edaOutputDataTypeTable',row-1,5);
                    rethrow(ME);
                end
                try
                    name=this.OutputDataTypeTableData{row,1};
                    bitWidth=str2num(this.OutputDataTypeTableData{row,2});%#ok<ST2NM>
                    dataType=this.OutputDataTypeTableData{row,3}.Entries{this.OutputDataTypeTableData{row,3}.Value+1};
                    if any(strcmp(this.OutputDataTypeTableData{row,3}.Entries{this.OutputDataTypeTableData{row,3}.Value+1},{'Fixedpoint','Integer'}))
                        if strcmp(this.OutputDataTypeTableData{row,4}.Entries{this.OutputDataTypeTableData{row,4}.Value+1},'Signed')
                            sign=true;
                        else
                            sign=false;
                        end
                    else
                        sign=false;
                    end
                    this.BuildInfo.addOutputDataType(name,bitWidth,dataType,sign,fracLen);
                catch ME
                    dlg.setFocus('edaOutputDataTypeTable');
                    dlg.selectTableItem('edaOutputDataTypeTable',row-1,5);
                    rethrow(ME);
                end

            end
            this.BuildInfo.validateOutputDataTypes;
            this.StepID=5;
        case 5
            dlg.refresh;
            this.BuildInfo.setOutputFolder(this.OutputFolder);


            this.BuildInfo.SkipFPGAProgFile=eda.internal.workflow.SkipFPGAProgFile;


            this.BuildInfo.AutoPortInfo=this.PortEditOption;


            success=this.buildFIL(dlg);

            if(success)
                closeDialog=true;
            end
        end
        delete(onCleanupObj);
    catch ME
        delete(onCleanupObj);
        this.Status=['Error: ',ME.message];
        this.lastErrorID=ME.identifier;
    end

    if(closeDialog)
        delete(dlg);
    else
        dlg.refresh;
    end

end



function r=l_eqPortTableData(this)


    r=true;

    newSize=size(this.NewPortTableData);
    oldSize=size(this.PortTableData);
    if(~all(newSize==oldSize))
        r=false;
        return;
    end

    for m=1:newSize(1)
        if(~strcmp(this.NewPortTableData{m,1},this.PortTableData{m,1})...
            ||(this.NewPortTableData{m,2}.Value~=this.PortTableData{m,2}.Value)...
            ||(~strcmp(this.NewPortTableData{m,3},this.PortTableData{m,3})))

            r=false;
            return;
        end
    end
end

function r=l_eqOutputDataTypeTableData(this)


    r=true;

    newSize=size(this.NewOutputDataTypeTableData);
    oldSize=size(this.OutputDataTypeTableData);
    if(~all(newSize==oldSize))
        r=false;
        return;
    end

    for m=1:newSize(1)
        if(~strcmp(this.NewOutputDataTypeTableData{m,1},this.OutputDataTypeTableData{m,1})...
            ||(~strcmp(this.NewOutputDataTypeTableData{m,2},this.OutputDataTypeTableData{m,2})))

            r=false;
            return;
        end
        newEntries=size(this.NewOutputDataTypeTableData{m,3}.Entries);
        oldEntries=size(this.OutputDataTypeTableData{m,3}.Entries);
        if(~all(newEntries==oldEntries))
            r=false;
            return;
        end

    end
end
