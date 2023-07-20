function modelReferenceSimTargetVerbose(obj)



    verobj=obj.ver;



    if isR2008aOrEarlier(verobj)
        modelName=obj.modelName;


        switch(get_param(modelName,'AccelVerboseBuild'))
        case{'on'}
            val='on';

        otherwise
            val='off';
        end


        obj.appendRule(['<Array<Simulink.DebuggingCC:insertpair ModelReferenceSimTargetVerbose ',val,'>>']);
    end
end
