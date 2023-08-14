function blockObjList=getFilteredBlockObjList(blockOPaths,sfPaths)











    blockObjList=get_param(blockOPaths,'Object');
    blockObjList=[blockObjList{:}];


    blockObjList=find(blockObjList,'-depth',0,'-isa','Simulink.Block',...
    '-not','-isa','Simulink.BlockDiagram',...
    '-not','-isa','Simulink.SubSystem',...
    '-not','-isa','Simulink.Scope',...
    '-not','-isa','Simulink.Display');%#ok


    len_blkList=length(blockObjList);
    omitList=zeros(1,len_blkList);

    for i=1:len_blkList
        curBlk=blockObjList(i);
        parent=curBlk.Parent;


        isBlockInportAndBusElementPort=...
        isa(curBlk,'Simulink.Inport')...
        &&strcmp(curBlk.IsBusElementPort,'on');
        if any(strcmp(sfPaths,parent))||isBlockInportAndBusElementPort
            omitList(i)=1;
        end
    end
    omitList=find(omitList);
    if~isempty(omitList)
        blockObjList(omitList)=[];
    end

end

