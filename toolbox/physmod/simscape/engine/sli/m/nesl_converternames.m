function[inputNames,outputNames]=nesl_converternames(bhandle,index)






    if nargin==1
        index=1;
    end

    graphInfo=get_param(bhandle,'MxParameters');

    inputNames={};
    for ii=graphInfo.inputs
        for dst=ii.dst
            if dst.dae==index
                inputNames{dst.index}=ii.src.block;%#ok
            end
        end
    end

    outputNames={};
    for oo=graphInfo.outputs
        if oo.src.dae==index
            outputNames{oo.src.index}=oo.dst{1}.block;%#ok
        end
    end

end
