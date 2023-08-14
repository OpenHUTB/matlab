function emitGlobalIO(this,codeWriter,methKind,GlobalIO,ioType)






    switch ioType
    case 'Output'
        ioObj=GlobalIO.Outputs;
        bufferName=['OutputIOBuffer_',this.LctSpecInfo.Specs.SFunctionName];
        wComment='Write global IO variables to block outputs';
        emitVariableAssign(this,codeWriter,bufferName,wComment,ioObj);

    case 'Input'
        ioObj=GlobalIO.Inputs;
        bufferName=['InputIOBuffer_',this.LctSpecInfo.Specs.SFunctionName];
        wComment='Read block inputs into global IO variable';
        emitVariableAssign(this,codeWriter,bufferName,wComment,ioObj);

    case 'Declare'
        emitExternGlobalIOVars(this,codeWriter,GlobalIO);

    case 'AssignPointer'
        emitAssignPointerIOVars(this,codeWriter,methKind,GlobalIO);

    otherwise

        assert(false,'ioType should be Output, Input or Declare');
    end
end



function emitVariableAssign(this,codeWriter,bufferName,wComment,ioObj)





    hasNonPointerPorts=any(~[ioObj.IsPointer]);
    if numel(ioObj)>0&&hasNonPointerPorts
        codeWriter.wComment(wComment);
        codeWriter.wLine('%%openfile %s',bufferName);
        for kPort=1:numel(ioObj)
            if~ioObj(kPort).IsPointer
                tmpStr=makeGlobalIOAssign(this,ioObj(kPort));
                codeWriter.wLine(tmpStr);
            end
        end
        codeWriter.wLine('%%closefile %s',bufferName);
        codeWriter.wLine('%%<%s>',bufferName);
    end

end



function emitAssignPointerIOVars(this,codeWriter,methKind,globalIO)





    globalPorts=[globalIO.Inputs,globalIO.Outputs];
    nGlobalPorts=numel(globalPorts);
    hasPointerPorts=any([globalPorts.IsPointer]);
    if hasPointerPorts
        codeWriter.wLine('%assign currentSrcFile = LibGetModelDotCFile()');
        codeWriter.wLine('%openfile PointerAssignBuffer');
        for kPort=1:nGlobalPorts
            if globalPorts(kPort).IsPointer
                str=makeExternPointerAssignment(this,methKind,globalPorts(kPort));
                codeWriter.wLine(str);
            end
        end
        codeWriter.wLine('%closefile PointerAssignBuffer');
        codeWriter.wLine('%<PointerAssignBuffer>');
    end

end



function emitExternGlobalIOVars(this,codeWriter,globalIO)






    globalPorts=[globalIO.Inputs,globalIO.Outputs];
    nGlobalPorts=numel(globalPorts);

    if nGlobalPorts>0
        codeWriter.wLine('%assign currentSrcFile = LibGetModelDotCFile()');
        codeWriter.wLine('%openfile DeclareBuffer');
        for kPort=1:nGlobalPorts
            codeWriter.wLine(makeVariableDefinition(this,globalPorts(kPort)));
        end
        codeWriter.wLine('%closefile DeclareBuffer');
        codeWriter.wLine('%%<LibSetSourceFileSection(currentSrcFile, "Declarations", %s)>','DeclareBuffer');
    end

end



function str=makeVariableDefinition(~,ioVar)





    currId=ioVar.VarSpec.Data.Id;
    targetVar=ioVar.TargetVar;

    if ioVar.IsExtern
        TLCDeclareVariable=sprintf('XrelDeclare%sVariable',ioVar.VarSpec.DataKind);
        TLCDeclarePointer=sprintf('XrelDeclare%sPointer',ioVar.VarSpec.DataKind);
        TLCDeclareArray=sprintf('XrelDeclare%sArray',ioVar.VarSpec.DataKind);
        if ioVar.VarSpec.PassedByValue&&~ioVar.IsPointer
            str=sprintf('%%<%s(block, %d, "%s")>',TLCDeclareVariable,currId-1,targetVar);
        elseif ioVar.IsPointer
            str=sprintf('%%<%s(block, %d, "%s")>',TLCDeclarePointer,currId-1,targetVar);
        else
            str=sprintf('%%<%s(block, %d, "%s", %d)>',TLCDeclareArray,currId-1,targetVar,ioVar.VarSpec.Data.Width);
        end
    else
        TLCValidateFunction='XrelValidateExportedGlobalVariable';
        str=sprintf('%%<%s(block, "%s", %d, "%s")>',TLCValidateFunction,ioVar.VarSpec.DataKind,currId-1,targetVar);
    end
end



function str=makeExternPointerAssignment(~,methKind,ioVar)






    assert(ioVar.IsPointer,'makeExternPointerAssignment should only be called on variables that are of a pointer type');

    currId=ioVar.VarSpec.Data.Id;
    targetVar=ioVar.TargetVar;

    TLCAssignPointer=sprintf('XrelAssign%sPointer',ioVar.VarSpec.DataKind);
    if strcmp(methKind,'Start')
        tlcBool='TLC_TRUE';
    else
        tlcBool='TLC_FALSE';
    end
    str=sprintf('%%<%s(block, %d, %s, "%s")>',TLCAssignPointer,currId-1,tlcBool,targetVar);

end



function str=makeGlobalIOAssign(~,ioVar)





    assert(~ioVar.IsPointer,'makeGlobalIOAssign should never be called for variables that are of a pointer type');

    TLCAssignVariable=sprintf('XrelAssign%sVariableSignal',ioVar.VarSpec.DataKind);
    TLCAssignArray=sprintf('XrelAssign%sArraySignal',ioVar.VarSpec.DataKind);

    targetVar=ioVar.TargetVar;
    currId=ioVar.VarSpec.Data.Id;
    currWidth=ioVar.VarSpec.Data.Width;

    if ioVar.VarSpec.PassedByValue

        str=sprintf('%%<%s(block, %d, "%s")>',TLCAssignVariable,currId-1,targetVar);
    else

        str=sprintf('%%<%s(block, %d, "%s", %d)>',TLCAssignArray,currId-1,targetVar,currWidth);
    end

end

