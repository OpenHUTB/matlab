function schema=GenPortSchema(varargin)

    pp=soc.blkcb.PortPlacement();


    blockName=varargin{1};
    switch blockName

    case 'Memory Channel'
        numWr=varargin{2};
        numRd=varargin{3};
        s2hWr=varargin{4};
        h2sRd=varargin{5};

        for widx=1:numWr
            if s2hWr(widx)
                pp.addAXIInterface('A4S2HWrSlaveMemCh');
            else
                pp.addAXIInterface('A4SWrSlaveMemCh');
            end
        end
        for ridx=1:numRd
            if h2sRd(ridx)
                pp.addAXIInterface('A4H2SRdMasterMemCh');
            else
                pp.addAXIInterface('A4SRdMasterMemCh');
            end
        end

    case 'Memory Controller'
        numMasters=varargin{2};
        numDiag=varargin{3};
        for midx=1:numMasters,pp.addAXIInterface('ReqDoneMemMaster');end
        for didx=1:numDiag,pp.addAXIInterface('Diagnostic');end

    case 'Register Channel'
        RegTableRW=varargin{2};
        sides={};
        types={};
        for r=1:numel(RegTableRW)
            switch RegTableRW{r}
            case{'W','w','Write','write'}
                sides=[sides,{'LEFT','RIGHT'}];%#ok<AGROW>
                types=[types,{'output','input'}];%#ok<AGROW>
            case{'R','r','Read','read'}
                sides=[sides,{'LEFT','RIGHT'}];%#ok<AGROW>
                types=[types,{'input','output'}];%#ok<AGROW>
            end
        end
        pp.addGroup(sides,types);


    case 'Dummy Master'
        numMasters=1;
        for midx=1:numMasters,pp.addAXIInterface('ReqDoneDummyMaster');end

    case 'Task Manager'
        numTasks=varargin{2};
        taskS=repmat({'BOTTOM'},[1,numTasks]);
        taskT=repmat({'output'},[1,numTasks]);
        pp.addGroup(taskS,taskT);

    case 'Stream Connector'
        sides={'LEFT','LEFT','LEFT','LEFT','RIGHT','RIGHT','RIGHT','RIGHT'};
        types={'input','input','input','output','output','output','output','input'};
        pp.addGroup(sides,types);

    case 'Stream FIFO'
        sides={'LEFT','LEFT','RIGHT','RIGHT','RIGHT','LEFT'};
        types={'input','input','output','output','input','output'};
        pp.addGroup(sides,types);

    case 'Video Stream Connector'
        sides={'LEFT','LEFT','RIGHT','RIGHT','LEFT','RIGHT'};
        types={'input','input','output','output','output','input'};
        pp.addGroup(sides,types);

    case 'Video Stream FIFO'
        sides={'LEFT','LEFT','RIGHT','RIGHT','RIGHT','LEFT'};
        types={'input','input','output','output','input','output'};
        pp.addGroup(sides,types);

    case 'A4S Source'
        pp.addAXIInterface('A4SWrMasterLocal');

    case 'A4S Sink'
        pp.addAXIInterface('A4SRdSlaveLocal');

    case 'IO Data Source'
        inPort=varargin{2};
        donePort=varargin{3};
        eventPort=varargin{4};


        if inPort
            sides={'LEFT','LEFT','LEFT'};%#ok<AGROW>
            types={'input','input','input'};%#ok<AGROW>
            pp.addGroup(sides,types)
        end


        if eventPort&&donePort
            sides=[{'RIGHT'},{'RIGHT'},{'RIGHT'}];%#ok<AGROW>
            types=[{'output'},{'output'},{'input'}];%#ok<AGROW>  
        elseif eventPort&&~donePort
            sides=[{'RIGHT'},{'RIGHT'},{'RIGHT'}];%#ok<AGROW>
            types=[{'output'},{'<spacer>'},{'output'}];%#ok<AGROW>  
        elseif~eventPort&&donePort
            sides=[{'RIGHT'},{'RIGHT'},{'RIGHT'}];%#ok<AGROW>
            types=[{'output'},{'<spacer>'},{'input'}];%#ok<AGROW>             
        elseif inPort
            sides=[{'RIGHT'},{'RIGHT'}];%#ok<AGROW>
            types=[{'<spacer>'},{'output'}];%#ok<AGROW>  
        else
            sides={'RIGHT'};%#ok<AGROW>
            types={'output'};%#ok<AGROW>           
        end
        pp.addGroup(sides,types);


    case 'IO Data Sink'
        outPort=varargin{2};
        donePort=varargin{3};
        eventPort=varargin{4};


        if eventPort&&donePort
            sides=[{'LEFT'},{'LEFT'},{'LEFT'}];%#ok<AGROW>
            types=[{'output'},{'input'},{'output'}];%#ok<AGROW>  
        elseif eventPort&&~donePort
            sides=[{'LEFT'},{'LEFT'},{'LEFT'}];%#ok<AGROW>
            types=[{'output'},{'<spacer>'},{'input'}];%#ok<AGROW>  
        elseif~eventPort&&donePort
            sides=[{'LEFT'},{'LEFT'},{'LEFT'}];%#ok<AGROW>
            types=[{'input'},{'<spacer>'},{'output'}];%#ok<AGROW>  
        elseif outPort
            sides=[{'LEFT'},{'LEFT'}];%#ok<AGROW>
            types=[{'<spacer>'},{'input'}];%#ok<AGROW>  
        else
            sides={'LEFT'};%#ok<AGROW>
            types={'input'};%#ok<AGROW>           
        end
        pp.addGroup(sides,types);


        if outPort
            sides={'RIGHT','RIGHT','RIGHT'};%#ok<AGROW>
            types={'output','output','output'};%#ok<AGROW>
            pp.addGroup(sides,types)
        end

    case 'Memory Traffic Generator'
        showPort=varargin{2};
        if showPort
            sides={'TOP','TOP'};%#ok<AGROW>
            types={'output','input'};%#ok<AGROW>
        else
            sides={'TOP'};%#ok<AGROW>
            types={'<spacer>'};%#ok<AGROW>
        end
        pp.addGroup(sides,types)


    case 'hsb_esb_ADSB_arm'
        numTasks=varargin{2};
        numA4SRd=varargin{3};
        numA4SWr=varargin{4};
        numRegWr=varargin{5};
        numRegRd=varargin{6};

        taskS=repmat({'TOP'},[1,numTasks]);
        taskT=repmat({'input'},[1,numTasks]);
        pp.addGroup(taskS,taskT);

        for midx=1:numA4SRd,pp.addAXIInterface('A4SRdSlaveLocal');end
        for midx=1:numA4SWr,pp.addAXIInterface('A4SWrMasterLocal');end

        regS=repmat({'BOTTOM'},[1,numRegWr+numRegRd]);
        regT=[repmat({'input'},[1,numRegRd]),repmat({'output'},[1,numRegWr])];
        pp.addGroup(regS,regT);

    case 'hsb_esb_ADSB_fpga'
        numA4Rd=varargin{2};
        numA4Wr=varargin{3};
        numRegWr=varargin{4};
        numRegRd=varargin{5};

        for midx=1:numA4Rd,pp.addAXIInterface('A4SRdSlaveLocal');end
        for midx=1:numA4Wr,pp.addAXIInterface('A4SWrMasterLocal');end

        regS=repmat({'BOTTOM'},[1,numRegWr+numRegRd]);
        regT=[repmat({'input'},[1,numRegWr]),repmat({'output'},[1,numRegRd])];
        pp.addGroup(regS,regT);


    case 'Test addGroup'
        newSides=varargin{2};
        newTypes=varargin{3};
        pp.addGroup(newSides,newTypes);
    end

    pp.finishPlacement();

    schema=pp.generateSchema();

end

