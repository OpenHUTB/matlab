



function callInfo=getStateflowCallInfo(block)
    callInfo=[];
    blockObj=get_param(block,'Object');
    sfchart=find(blockObj,'-isa','Stateflow.Chart');
    if numel(sfchart)==1
        encodedData=sf('Cg','get_encoded_postcodegen_info',sfchart.Id);
        if~isempty(encodedData)
            postCodegenData=sf('Cg','mx_decode',encodedData);
            if numel(postCodegenData)==1
                callInfo=postCodegenData.customCodeCallInfo;
            end
        end
    end
