function loopObjects=loop_getLoopObjects(this,varargin)







    searchOptions=locGetSimulinkFindVarsSeachOptions(this,varargin{:});

    adSL=rptgen_sl.appdata_sl;
    switch lower(adSL.getContextType(this,false))
    case 'model'
        loopObjects=Simulink.findVars(...
        bdroot(adSL.ReportedSystemList{1}),...
        searchOptions{:});
        loopObjects=locFilterBySystem(loopObjects,adSL.ReportedSystemList);

    case 'system'
        loopObjects=Simulink.findVars(...
        adSL.CurrentSystem,...
        searchOptions{:});
        loopObjects=locFilterBySystem(loopObjects,adSL.CurrentSystem);

    case 'block';
        loopObjects=Simulink.findVars(adSL.CurrentBlock,searchOptions{:});

    case{'signal','annotation'}
        loopObjects=[];

    case 'workspacevar'
        loopObjects=adSL.CurrentWorkspaceVar;

    otherwise
        loopObj=rptgen_sl.rpt_mdl_loop_options();
        loopObj.MdlName='$all';
        allOpenedModels=loopObj.getModelNames();
        loopObjects=Simulink.findVars(allOpenedModels,searchOptions{:});
    end


    if strcmp(this.SortBy,'datatype')
        loopObjects=locSortByType(loopObjects);
    end


    function searchOptions=locGetSimulinkFindVarsSeachOptions(this,varargin)


        if this.isFilterList
            filterTerms=this.FilterTerms(:);

        elseif~isempty(varargin)
            filterTerms=varargin;

        else
            filterTerms={};
        end

        searchOptions=[...
        'SearchMethod','cached'...
        ,'RegExp','on'...
        ,'ReturnResolvedVar',true...
        ,filterTerms(:)'];



        function out=locFilterBySystem(in,sys)


            numberOfInputs=length(in);
            keep=false(1,numberOfInputs);
            for i=1:numberOfInputs
                parents=strrep(get_param(in(i).UsedByBlocks,'Parent'),char(10),' ');
                if any(ismember(parents,sys))
                    keep(i)=true;
                end
            end

            out=in(keep);


            function out=locSortByType(in)


                if~isempty(in)
                    ps=rptgen_sl.propsrc_sl_ws_var();

                    type=ps.getPropValue(in,'DataType');
                    name={in(:).Name};
                    type_name=[type(:),name(:)];
                    [~,sortedIndex]=sortrows(type_name,[1,2]);
                    out=in(sortedIndex);
                else
                    out=in;
                end

