function problems=formatProblems(problems)




    if isempty(problems)
        problems="";
        return
    end
    problems=arrayfun(@(p)string(p.Name),problems);
    problems=join(problems,", ");
end
