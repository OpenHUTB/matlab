function output=restore(model,varargin)




















    parser=restorepoint.internal.restore.restoreParser;
    parse(parser,varargin{:});
    inputs=parser.Results;


    restorer=initializeRestorer(inputs,model);
    output=restorer.run;
end

function restorer=initializeRestorer(inputs,model)



    restoreDataStrategy=restorepoint.internal.restore.RestorePointRestoreData;
    restoreDataStrategy.setModelName(model);
    restoreStrategy=restorepoint.internal.restore.RestorePointRestoreStrategy;

    if isequal(inputs.prerestoreclosefiles,'all')
        preRestoreStrategy=restorepoint.internal.restore.PreRestoreCloseAllElements;
    elseif(isequal(inputs.prerestoreclosefiles,'modified'))
        preRestoreStrategy=restorepoint.internal.restore.PreRestoreCloseModifiedElement;
    end


    if inputs.postrestoreloadstate
        postRestoreStrategy=restorepoint.internal.restore.PostRestoreLoadModelState;
    else
        postRestoreStrategy=restorepoint.internal.restore.PostRestoreNoLoad;
    end

    restorer=restorepoint.internal.Restorer...
    (restoreDataStrategy,preRestoreStrategy,restoreStrategy,postRestoreStrategy);
end


