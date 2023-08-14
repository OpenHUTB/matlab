function[inArgs,outArgs,fcnName]=getSLFcnInOutArgs(blk)




    inArgs={};
    outArgs={};
    fcnName='';
    if strcmp(get_param(blk,'BlockType'),'FunctionCaller')||...
        coder.mapping.internal.SimulinkFunctionMapping.isSimulinkFunction(blk)
        fcnProto=get_param(blk,'FunctionPrototype');
        if contains(fcnProto,'=')
            outArgsStr=regexp(fcnProto,...
            '\[?\s*([^\=\]]+)\]?\s*\=','tokens');
            outArgsStr=strtrim(char(outArgsStr{1}));
            if(~isempty(outArgsStr))
                outArgs=regexp(outArgsStr,'\s*,\s*','split');
            end
        end
        inArgsStr=regexp(fcnProto,'\w+\(([^\)]*)\)','tokens');
        if~isempty(inArgsStr)
            inArgsStr=strtrim(char(inArgsStr{1}));
            if(~isempty(inArgsStr))
                inArgs=regexp(inArgsStr,'\s*,\s*','split');
            end
        end
        fcnName=regexp(fcnProto,'(\w+)\s*\(','tokens');
        if isempty(fcnName)
            DAStudio.error('Simulink:FcnCall:FcnCallPrototypeInvalid',fcnProto);
        end
        fcnName=char(fcnName{1});
    end
end
