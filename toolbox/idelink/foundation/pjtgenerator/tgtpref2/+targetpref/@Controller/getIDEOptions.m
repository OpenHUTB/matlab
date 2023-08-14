function options=getIDEOptions(h,connectToIDE)




    options={};
    try
        switch(h.mData.getTag())
        case{'ccslinktgtpref','ccslinktgtpref_c64xp'},
            options=i_fillOptionsCCS(h,connectToIDE);
        case{ticcsext.Utilities.getTICCSv4('tag'),...
            ticcsext.Utilities.getTICCSv4('tag64xp'),...
            ticcsext.Utilities.getTICCSv5('tag'),...
            ticcsext.Utilities.getTICCSv5('tag64xp')}


        case 'multilinktgtpref',

        case 'vdsplinktgtpref',
            options=i_fillOptionsVDSP(h,connectToIDE);
        end
    catch %#ok<CTCH>

    end

    function options=i_fillOptions(h,connectToIDE,Name1,Name2)
        options{1}=h.getDynamicWidgetTemplate();
        options{2}=h.getDynamicWidgetTemplate();
        options{1}.Name=Name1;
        options{1}.Type='combobox';
        options{1}.Entries={};
        options{1}.Value='';
        options{1}.Enabled=connectToIDE;
        options{1}.RowSpan=[1,1];
        options{2}.Name=Name2;
        options{2}.Type='combobox';
        options{2}.Entries={};
        options{2}.Value='';
        options{2}.Enabled=connectToIDE;
        options{2}.RowSpan=[2,2];

        function options=i_findBestMatch(h,options)
            stored=h.mData.getIDEOptions();
            options{1}.Entries=options{1}.Data;
            found=strmatch(stored{1},options{1}.Data);
            if(~isempty(found))
                options{1}.Value=options{1}.Data{found(1)};
                options{2}.Entries=options{2}.Data{found(1)};
                found2=strmatch(stored{2},options{2}.Entries);
                if(~isempty(found2))
                    options{2}.Value=options{2}.Entries{found2(1)};
                else
                    options{2}.Value=options{2}.Entries{1};
                end
            else
                options{1}.Value=options{1}.Data{1};
                options{2}.Entries=options{2}.Data{1};
                options{2}.Value=options{2}.Data{1}{1};
            end

            function options=i_fillOptionsCCS(h,connectToIDE,Name1,Name2)
                options=i_fillOptions(h,connectToIDE,'Board Name:','Processor Name:');
                if(connectToIDE)
                    ex=[];
                    try
                        availConfigs=ccsboardinfo;
                        numBoards=length(availConfigs);
                    catch ex
                        numBoards=0;
                    end
                    if(numBoards<1)
                        if(~isempty(ex))
                            h.showError('tgtpref:GetIDESettings',ex.message);
                        else
                            h.showError('tgtpref:VerifyIDESetup');
                        end
                        options=i_fillOptions(h,false,'Board Name:','Processor Name:');
                        return;
                    end
                    [boardList{1:numBoards}]=deal(availConfigs.name);
                    procList=cell(1,numBoards);
                    for i=1:numBoards,
                        procStruct=availConfigs(i).proc;
                        numProcs=length(procStruct);
                        procName={};



                        for j=1:numProcs
                            if isnumeric(procStruct(j).number)
                                procName{end+1}=procStruct(j).name;%#ok<AGROW>
                            end
                        end
                        if isempty(procName)

                            procList{i}={' '};
                        else
                            procList{i}=procName;
                        end
                    end
                    options{1}.Data=boardList;
                    options{2}.Data=procList;
                    options=i_findBestMatch(h,options);
                end

                function options=i_fillOptionsVDSP(h,connectToIDE)
                    options=i_fillOptions(h,connectToIDE,'Session Name:','Processor Name:');
                    if(connectToIDE)
                        ex=[];
                        try
                            availConfigs=listsessions('verbose');
                            numBoards=length(availConfigs);
                        catch ex
                            numBoards=0;
                        end
                        if(numBoards<1)
                            if(~isempty(ex))
                                h.showError('tgtpref:GetIDESettings',ex.message);
                            else
                                h.showError('tgtpref:VerifyIDESetup');
                            end
                            options=i_fillOptions(h,false,'Session Name:','Processor Name:');
                            return;
                        end
                        boardList=cell(1,numBoards);
                        procList=cell(1,numBoards);
                        for i=1:numBoards,
                            boardList{i}=availConfigs{i}.sessionname;
                            procList{i}=cellstr(availConfigs{i}.processors);
                        end
                        options{1}.Data=boardList;
                        options{2}.Data=procList;
                        options=i_findBestMatch(h,options);
                    end
