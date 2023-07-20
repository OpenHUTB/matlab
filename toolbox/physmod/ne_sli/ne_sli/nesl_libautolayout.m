function nesl_libautolayout(hSystem,arrangeBlocks,layoutFunction)













    hSystem=get_param(hSystem,'Handle');

    if nargin<2
        arrangeBlocks=true;
    end


    if nargin<3
        layoutFunction=@pm.sli.libautolayout;
    end


    layoutFunction(hSystem,arrangeBlocks);



    subLibraries=find_system(hSystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Tag','simscape_sublibrary');


    subLibraries(subLibraries==hSystem)=[];


    for idx=1:numel(subLibraries)
        layoutFunction(subLibraries(idx));
    end

end

