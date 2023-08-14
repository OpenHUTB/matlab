




function ioVarInfo=extractIOVarInfo(aCodegenReport,fcnName)

    ioVarInfo=[];
    for i=1:numel(aCodegenReport.inference.Functions)
        if strcmp(aCodegenReport.inference.Functions(i).FunctionName,fcnName)
            ioVarInfo=getSizeInfo(aCodegenReport,i);
            return
        end
    end


    function sizeInfo=getSizeInfo(aCodegenReport,idx)
        sizeInfo.inputs=[];
        sizeInfo.outputs=[];
        varInfo=aCodegenReport.inference.Functions(idx).MxInfoLocations;
        script=aCodegenReport.inference.Scripts(aCodegenReport.inference.Functions(idx).ScriptID).ScriptText;
        mxInfos=aCodegenReport.inference.MxInfos;

        for i=1:numel(varInfo)
            if strcmp(varInfo(i).NodeTypeName,'inputVar')
                name=script(varInfo(i).TextStart+1:varInfo(i).TextStart+varInfo(i).TextLength);
                sizeInfo.inputs=[sizeInfo.inputs...
                ,struct('type','input','name',name,'info',mxInfos{varInfo(i).MxInfoID})];
            elseif strcmp(varInfo(i).NodeTypeName,'outputVar')
                name=script(varInfo(i).TextStart+1:varInfo(i).TextStart+varInfo(i).TextLength);
                sizeInfo.outputs=[sizeInfo.inputs...
                ,struct('type','output','name',name,'info',mxInfos{varInfo(i).MxInfoID})];
            end
        end