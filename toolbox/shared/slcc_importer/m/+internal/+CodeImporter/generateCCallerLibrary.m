function generateCCallerLibrary(obj,isOverwrite)

    OutputFolder=obj.qualifiedSettings.OutputFolder;
    updateLib=~isOverwrite;


    if(obj.importAsLibrary)
        ModelType='library';
    else
        ModelType='model';
    end

    if updateLib&&isfile(fullfile(OutputFolder,obj.LibraryFileName+".slx"))
        hMdl=load_system(fullfile(OutputFolder,obj.LibraryFileName+".slx"));
        set_param(obj.LibraryFileName,'Lock','off');
    else
        hMdl=safeCreateModel(obj,obj.LibraryFileName,ModelType);
    end


    save_system(hMdl,fullfile(OutputFolder,obj.LibraryFileName+".slx"));


    if~obj.Options.BuildForIPProtection
        internal.CodeImporter.updateLibraryConfigSetSettings(obj,hMdl);
    end


    set_param(hMdl,'EnableLBRepository','on');


    slcc('parseCustomCode',hMdl,true);



    if isOverwrite
        slcc('invalidateAllSLCCFunctions',hMdl);
    end


    symbols=slcc('getExportedSymbols',hMdl);


    if obj.Options.ImportTypesToFile
        internal.CodeImporter.importSpecialTypesToFile(obj);
    else
        internal.CodeImporter.importSpecialTypes(obj,updateLib);
    end









    assert(bdIsLoaded(obj.LibraryFileName));


    existingCCallerBlkHandles=Simulink.findBlocksOfType(obj.LibraryFileName,'CCaller');



    existingCCallerBlkMappedFcnNames=...
    get_param(existingCCallerBlkHandles,'FunctionName');



    fcnsToAdd=setdiff(obj.FunctionsToImport,existingCCallerBlkMappedFcnNames);





    updateBlkIndex=ismember(existingCCallerBlkMappedFcnNames,obj.FunctionsToImport);

    blocksToUpdate=existingCCallerBlkHandles(updateBlkIndex);
    blocksToComment=existingCCallerBlkHandles(~updateBlkIndex);

    pos=zeros(1,5);
    if updateLib

        blks=find_system(obj.LibraryFileName);
        for idx=2:numel(blks)
            blk=blks{idx};
            blkPos=get_param(blk,'Position');
            pos(2)=max(pos(2),blkPos(4));
            lineSpace=30;
            pos(2)=pos(2)+lineSpace;
        end

        commentOutRemovedFunctions(blocksToComment);


        refreshBlockSLCCFunctions(blocksToUpdate);
    end


    availableFcns=intersect(obj.ParseInfo.AvailableFunctions,symbols.functions);
    for i=1:length(availableFcns)
        fcnSettings=obj.getCachedFunctionSettings(availableFcns{i});
        if~isempty(fcnSettings)&&~isempty(fcnSettings.PortSpecArray)
            slcc('updateSLCCFcnFromArgsInfo',hMdl,fcnSettings.PortSpecArray,availableFcns{i});





            slcc('invalidateSLCCFunction',hMdl,availableFcns{i},true);


        elseif~strcmpi(obj.Options.PassByPointerDefaultSize,"-1")
            functionPortSpecification=slcc('getFunctionPortSpec',hMdl,availableFcns{i});
            allArguments=[functionPortSpecification.ReturnArgument...
            ,functionPortSpecification.InputArguments...
            ,functionPortSpecification.GlobalArguments];
            for arg=allArguments
                if strcmpi(arg.Size,"-1")
                    arg.Size=obj.Options.PassByPointerDefaultSize;
                end
            end
            slcc('invalidateSLCCFunction',hMdl,availableFcns{i},true);
        end
    end

    addNewFunctions(obj,fcnsToAdd,pos);
    if updateLib
        refreshBlockSLCCFunctions(blocksToUpdate);
    end

    save_system(hMdl,fullfile(OutputFolder,obj.LibraryFileName+".slx"));

    if obj.Options.CreateTestHarness

        internal.CodeImporter.generateTestFile(obj,isOverwrite);
    end

    if~isempty(char(obj.Options.LibraryBrowserName))
        if(isa(obj,'sltest.CodeImporter'))
            warning(message('Simulink:CodeImporter:GenerateSLBlocksIgnored'));
        else

            generateSLBlocksScript(obj.LibraryFileName,OutputFolder,obj.Options.LibraryBrowserName);
        end
    end


    open_system(hMdl);

end

function addNewFunctions(obj,fcnsToAdd,pos)




    cCallerPath='simulink/User-Defined Functions/C Caller';

    for j=1:length(fcnsToAdd)
        newBlockPath=[obj.LibraryFileName.char,'/',fcnsToAdd{j}];
        hBlk=add_block(cCallerPath,newBlockPath);
        set_param(hBlk,'FunctionName',fcnsToAdd{j});
        numPorts=get_param(hBlk,'Ports');
        blockName=get_param(hBlk,'Name');
        pos=genBlockPosition(pos,numPorts,blockName);
        set_param(hBlk,'Position',pos(1:4));
        if obj.autoCreatePorts
            addports(hBlk,obj.LibraryFileName.char,pos,numPorts,blockName);
        end
    end
end

function commentOutRemovedFunctions(blocksToComment)

    for idx=1:numel(blocksToComment)
        set_param(blocksToComment(idx),'commented','on');
    end
end

function refreshBlockSLCCFunctions(blocksToUpdate)




    for idx=1:numel(blocksToUpdate)
        set_param(blocksToUpdate(idx),'commented','off');




        fcnName=get_param(blocksToUpdate(idx),'FunctionName');
        linkStatus=get_param(blocksToUpdate(idx),'LinkStatus');
        if~strcmpi(linkStatus,'resolved')
            set_param(blocksToUpdate(idx),'FunctionName',fcnName);
        end
    end
end

function pos=genBlockPosition(pos,numPorts,blockName)
    leftY=pos(2);rightX=pos(3);height=pos(5);
    maxLineWidth=600;
    lineSpace=30;
    minBlockWidth=70;
    maxBlockWidth=200;
    heightPerPort=50;
    widthPerFcnNameChar=10;
    widthBetweenBlocks=50;
    baseHeight=30;
    leftX=rightX+widthBetweenBlocks;

    if leftX>maxLineWidth
        leftX=0;
        leftY=height+lineSpace;
    end

    rightX=leftX+min(max(length(blockName)*widthPerFcnNameChar,minBlockWidth),maxBlockWidth);
    rightY=leftY+baseHeight+max(numPorts(1),numPorts(2))*heightPerPort;
    if(rightY>height);height=rightY;end
    pos=[leftX,leftY,rightX,rightY,height];
end

function addports(blk,newLibName,pos,numPorts,blockName)
    leftPortX=pos(1)-30;
    rightPortX=pos(3)+30;
    portY=(pos(2)+pos(4)/2);
    h=get_param(blk,'PortHandles');

    for i=1:numPorts(1)
        newInportPath=sprintf('%s/%sIn%d',newLibName,blockName,i);
        inBlk=add_block('simulink/Commonly Used Blocks/In1',newInportPath);
        set_param(newInportPath,'position',[leftPortX,portY,leftPortX+25,portY+15]);
        hIn=get_param(inBlk,'PortHandles');
        add_line(newLibName,hIn.Outport(1),h.Inport(i));
    end

    for i=1:numPorts(2)
        newOutportPath=sprintf('%s/%sOut%d',newLibName,blockName,i);
        inBlk=add_block('simulink/Commonly Used Blocks/Out1',newOutportPath);
        set_param(newOutportPath,'position',[rightPortX,portY,rightPortX+25,portY+15]);
        hOut=get_param(inBlk,'PortHandles');
        add_line(newLibName,h.Outport(i),hOut.Inport(1));
    end
end

function hMdl=safeCreateModel(obj,newLibName,ModelType)
    nameExistBD=bdIsLoaded(newLibName);
    modelPath=fullfile(obj.qualifiedSettings.OutputFolder,newLibName+".slx");
    if nameExistBD
        close_system(newLibName,0);
    end
    nameExistPath=isfile(modelPath);
    if nameExistPath
        delete(modelPath);
    end
    hMdl=new_system(newLibName,ModelType);
end

function generateSLBlocksScript(LibraryFileName,libraryFolder,libraryBrowserName)
    commentHeader="%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"+newline+...
    "% Automatically generated "+string(datestr(now))+"         "+newline+...
    "% This file can be edited to specify a different library name in Simulink Library Browser"+newline+newline;

    slBlockScript="function blkStruct = slblocks"+newline+...
    "% This function specifies that the library should appear"+newline+...
    "% in the Library Browser"+newline+...
    "% and be cached in the browser repository"+newline+...
    "Browser.Library = '"+string(LibraryFileName)+"';"+newline+...
    "% name of the generated Simulink library"+newline+newline+...
    "Browser.Name = '"+string(libraryBrowserName)+"';"+newline+...
    "% library name that appears in the Library Browser"+newline+newline+...
    "blkStruct.Browser = Browser;";

    [fid,fError]=fopen(fullfile(libraryFolder,'slblocks.m'),'w');
    if fid==-1
        topErrMsg=MException(message('Simulink:CodeImporter:UnableToOpenSLBlocksFile',libraryFolder));
        causeErrMsg=MException(message(fError));
        topErrMsg=addCause(topErrMsg,causeErrMsg);
        throw(topErrMsg);
    end
    fprintf(fid,"%s",commentHeader+slBlockScript);
    fclose(fid);
end