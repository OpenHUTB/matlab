function initFLLInstruction(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end


    slplc.utils.modelSanityChecker(block);

    fllInfo=slplc.api.getPOU(block);
    dsmExprName=fllInfo.PLCOperandExpression;

    [dsmName,dsmExprName]=slplc.utils.parseExpression(dsmExprName);
    assert(iscell(dsmName)&&length(dsmName)==1,['Operand parsing for :',dsmExprName,' unsuccessful']);

    emlBlock=findEMLBlock(block);
    updateEMLScript(block,emlBlock,dsmName{1},replaceCurlyBraces(dsmExprName))

end

function out=replaceCurlyBraces(dsmExprName)
    out=strrep(dsmExprName,'{','(');
    out=strrep(out,'}',')');
end

function updateEMLScript(fllBlock,emlBlock,dsmName,dsmExprName)
    emlObj=get_param(emlBlock,'Object');
    emlChart=find(emlObj,'-isa','Stateflow.EMChart');
    chartID=sfprivate('block2chart',emlBlock);


    dataID=sf('get',chartID,'.childData');
    dsmDataIDIndex=sf('get',dataID,'.scope')==11;
    sf('set',dataID(dsmDataIDIndex),'.name',dsmName);


    script=getEMLScript(fllBlock,dsmName,dsmExprName);
    emlChart.Script=script;
end

function out=findEMLBlock(fllBlock)

    out=plc_find_system(fllBlock,'SearchDepth',2,'LookUnderMasks','all','FollowLinks','on','Name','MATLAB Function');
    assert(~isempty(out)&&length(out)==1,['Unexpected MATLAB function block in :',fllBlock]);
    out=out{1};
end

function out=getEMLScript(fllBlock,dsmName,dsmExprName)


    fllBlockPath=getfullname(fllBlock);
    out=['function fcn(src, fllLength, destStartIndex)',newline...
    ,newline...
    ,'global ',dsmName,' ;',newline...
    ,newline...
    ,'outType = class(',dsmExprName,'(1));',newline...
    ,'srcType = class(src);',newline...
    ,'if ~strcmp(outType,srcType)',newline...
    ,'   error(''plccoder:plccore:COPFLLTypeConversionNotSupported'', ''Type conversion between source of type : %s and destination of type %s not supported for block : %s'', srcType , outType, ''',fllBlockPath,''');',newline...
    ,'end',newline...
    ,'destLength = length(',dsmExprName,');',newline...
    ,newline...
    ,'minLength = min([(destLength-destStartIndex), fllLength]);',newline...
    ,newline...
    ,'for ii=1:minLength',newline...
    ,'     ',dsmExprName,'(ii + destStartIndex) = src;',newline...
    ,'end',newline];
end


