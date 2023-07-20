function[bList,badList]=findContextBlocks(adSL,varargin)





    switch lower(adSL.Context)
    case 'system'
        currSys=adSL.CurrentSystem;
        bList=rptgen_sl.rgFindBlocks(currSys,...
        1,...
        varargin);


        bList=setdiff(bList,currSys);
    case 'signal'
        currSig=adSL.CurrentSignal;
        if isequal(currSig,-1)
            bList={};
            badList={};
        else
            bList=rptgen_sl.rgFindBlocks(LocConnectedBlocks(currSig),...
            0,...
            varargin);
        end
    case 'block'
        bList=rptgen_sl.rgFindBlocks(adSL.CurrentBlock,...
        0,...
        varargin);
    case 'model'
        sysList=adSL.ReportedSystemList;
        bList=rptgen_sl.rgFindBlocks(sysList,...
        1,...
        varargin);


        bList=setdiff(bList,sysList);
    case{'annotation','configset','workspacevar'}
        bList={};
    otherwise
        mList=find_system('SearchDepth',1,...
        'BlockDiagramType','model');
        mList=setdiff(mList,{'temp_rptgen_model'});
        bList=rptgen_sl.rgFindBlocks(mList,...
        [],...
        varargin);

    end


    function bList=LocConnectedBlocks(currSig)


        bList={};
        if~isempty(currSig)
            try
                lineHandle=get_param(currSig,'Line');
            catch
                lineHandle=-1;
            end

            if ishandle(lineHandle)
                try
                    bHandles=[get_param(lineHandle,'SrcBlockHandle')
                    get_param(lineHandle,'DstBlockHandle')];
                catch
                    bHandles=[];
                end

                bHandles=bHandles(ishandle(bHandles));

                for i=length(bHandles):-1:1
                    bList{i}=getfullname(bHandles(i));
                end
            else

                bList={get_param(currSig,'Parent')};
            end
        end
