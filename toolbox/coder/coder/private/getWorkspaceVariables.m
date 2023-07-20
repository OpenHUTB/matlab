

function[vars]=getWorkspaceVariables()

    vars=extractInfo(evalin('base','whos'));

end


function[varInfo]=extractInfo(rawVars)
    numVars=numel(rawVars);
    varInfo=repmat(struct('name','','size',[],'matlabClass','','complex',false),[numVars,1]);

    for i=1:numel(rawVars)
        varInfo(i).name=rawVars(i).name;
        varInfo(i).dimensions=rawVars(i).size;
        varInfo(i).matlabClass=rawVars(i).class;
        varInfo(i).complex=rawVars(i).complex;
    end
end