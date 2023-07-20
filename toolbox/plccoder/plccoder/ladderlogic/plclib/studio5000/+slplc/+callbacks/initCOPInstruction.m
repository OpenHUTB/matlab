function initCOPInstruction(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end


    slplc.utils.modelSanityChecker(block);

    copInfo=slplc.api.getPOU(block);
    dsmExprName=copInfo.PLCOperandExpression;

    [dsmName,dsmExprName]=slplc.utils.parseExpression(dsmExprName);
    assert(iscell(dsmName)&&length(dsmName)==1,['Operand parsing for :',dsmExprName,' unsuccessful']);

    emlBlock=findEMLBlock(block);
    updateEMLScript(block,emlBlock,dsmName{1},dsmExprName)

end

function updateEMLScript(copBlock,emlBlock,dsmName,dsmExprName)
    emlObj=get_param(emlBlock,'Object');
    emlChart=find(emlObj,'-isa','Stateflow.EMChart');
    chartID=sfprivate('block2chart',emlBlock);


    dataID=sf('get',chartID,'.childData');
    dsmDataIDIndex=sf('get',dataID,'.scope')==11;
    sf('set',dataID(dsmDataIDIndex),'.name',dsmName);


    script=getEMLScript(copBlock,dsmName,dsmExprName);
    emlChart.Script=script;
end

function out=findEMLBlock(copBlock)

    out=plc_find_system(copBlock,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','Name','MATLAB Function');
    assert(~isempty(out)&&length(out)==1,['Unexpected MATLAB function block in :',copBlock]);
    out=out{1};
end

function out=getEMLScript(copBlock,dsmName,dsmExprName)


    copBlockPath=getfullname(copBlock);
    out=['function fcn(src, copLength, srcStartindex, destStartIndex)',newline...
    ,newline...
    ,'global ',dsmName,' ;',newline...
    ,newline...
    ,'outType = class(',dsmExprName,'(1));',newline...
    ,'srcType = class(src);',newline...
    ,'if ~strcmp(outType,srcType)',newline...
    ,'   error(''plccoder:plccore:COPFLLTypeConversionNotSupported'', ''Type conversion between source of type : %s and destination of type %s not supported for block : %s'', srcType , outType, ''',copBlockPath,''');',newline...
    ,'end',newline...
    ,'destLength = length(',dsmExprName,');',newline...
    ,newline...
    ,'minLength = min([ (length(src) - srcStartindex), (destLength -destStartIndex), copLength]);',newline...
    ,newline...
    ,'for ii=1:minLength',newline...
    ,'     ',dsmExprName,'(ii + destStartIndex) = src(ii + srcStartindex);',newline...
    ,'end',newline];
end


