function ret=getSetNewDataAvailable(mdl,val)



    if nargin<2

        val=get_param(mdl,'SDINewDataAvailable');
        ret=isequal(val,true);
    elseif~isempty(mdl)

        if bdIsLoaded(mdl)
            set_param(mdl,'SDINewDataAvailable',logical(val));
        end
        ret=logical(val);
    else

        if is_simulink_loaded
            mdls=find_system('type','block_diagram');
            for idx=1:length(mdls)
                if~strcmpi(get_param(mdls{idx},'BlockDiagramType'),'library')&&...
                    ~strcmpi(get_param(mdls{idx},'lock'),'on')
                    set_param(mdls{idx},'SDINewDataAvailable',logical(val));
                end
            end
        end
        ret=logical(val);
    end
end
