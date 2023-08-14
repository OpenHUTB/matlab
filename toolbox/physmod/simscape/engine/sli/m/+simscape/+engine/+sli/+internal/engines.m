function out=engines(model)












    narginchk(1,nargin);
    cs=simscape.engine.sli.internal.compiledSystems(model);
    out=cell(length(cs),1);
    for i=1:length(cs)
        if isa(cs{i},'simscape.LtiData')
            thisengine='lti';
        elseif isa(cs{i},'simscape.SwlData')
            thisengine='swl';
        else
            thisengine='default';
        end
        out{i}=thisengine;
    end

end
