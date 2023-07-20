

function[result,violationObjs]=hasNoDefaultTransition(...
    defaultTransitions,sfObjs)
    violationObjs=[];
    result=true;





    if isempty(defaultTransitions)

        if isempty(sfObjs)
            result=false;
            return;
        end



        sinkedTrans=arrayfun(@(x)x.sinkedTransitions,sfObjs,...
        'UniformOutput',false);

        if isempty(sinkedTrans)

            violationObjs=sfObjs;
            return;
        end

        sinkedTrans=vertcat(sinkedTrans{:});
        if isempty(sinkedTrans.find('Source',[]))

            violationObjs=sfObjs;
            return;
        end
    end

    result=false;
end
