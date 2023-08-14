function toolNameList=getToolNameList(obj)





    if obj.hAvailableToolList.isToolListEmpty
        toolNameList={obj.NoAvailableToolStr};
    else
        availableToolList=obj.hAvailableToolList.getToolNameList;
        boardName=obj.get('Board');
        if strcmpi(boardName,'')||strcmpi(boardName,obj.EmptyBoardStr)||strcmpi(boardName,obj.GetMoreStr)

            toolNameList=[availableToolList,{obj.EmptyToolStr}];

            if obj.isHLSWorkflow
                removeNonHLSTools();
            else
                removeHLSTools();
            end
            if~strcmp(obj.get('Workflow'),obj.GenericWorkflowStr)


                removeMicrosemiLiberoSoC();



                removeIntelQuartusPro();
            end
        else

            toolNameList=obj.getAvailableToolForBoard(boardName);
        end
    end

    function removeMicrosemiLiberoSoC()
        toolNameListii={};
        for ii=1:numel(toolNameList)
            if~strcmpi(toolNameList{ii},'Microchip Libero SoC')
                toolNameListii{end+1}=toolNameList{ii};%#ok<AGROW>
            end
        end
        toolNameList=toolNameListii;
    end



    function removeIntelQuartusPro()
        toolNameListii={};
        for ii=1:numel(toolNameList)
            if~strcmpi(toolNameList{ii},'Intel Quartus Pro')
                toolNameListii{end+1}=toolNameList{ii};%#ok<AGROW>
            end
        end
        toolNameList=toolNameListii;
    end



    function removeNonHLSTools()
        toolNameListii={};
        for ii=1:numel(toolNameList)
            if strcmpi(toolNameList{ii},'Cadence Stratus')||...
                (hdlfeature('MLHDLSystemCVitisHLS')=="on"&&strcmpi(toolNameList{ii},'Xilinx Vitis HLS'))||...
                strcmpi(toolNameList{ii},obj.EmptyToolStr)
                toolNameListii{end+1}=toolNameList{ii};%#ok<AGROW>
            end
        end
        toolNameList=toolNameListii;
    end



    function removeHLSTools()
        toolNameListii={};
        for ii=1:numel(toolNameList)
            if~strcmpi(toolNameList{ii},'Cadence Stratus')&&...
                ~strcmpi(toolNameList{ii},'Xilinx Vitis HLS')
                toolNameListii{end+1}=toolNameList{ii};%#ok<AGROW>
            end
        end
        toolNameList=toolNameListii;
    end
end
