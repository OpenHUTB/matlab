function schema





    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');
    this=schema.class(pkg,'rpt_mdl_loop_options',pkgRG.findclass('DAObject'));

    rptgen.prop(this,'Active','bool',true,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:activeLabel')));

    p=rptgen.prop(this,'MdlName',rptgen.makeStringType,'$current',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelNameLabel')),1);
    p.SetFunction=@setMdlName;



    p=rptgen.prop(this,'MdlCurrSys','MATLAB array',{'$top'},getString(message('RptgenSL:rsl_rpt_mdl_loop_options:startingSystemsLabel')),1);
    p.SetFunction=@setMdlCurrSys;


    rptgen.prop(this,'SysLoopType',{
    'current',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:selectedOnlyLabel'))
    'currentAbove',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:selectedAndUpLabel'))
    'all',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allSystemsInModelLabel'))
    'currentBelow',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:selectedAndDownLabel'))
    },'all',...
    getString(message('RptgenSL:rsl_rpt_mdl_loop_options:traverseModelLabel')),1);


    rptgen.prop(this,'isMask',{
    'none',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:noMasksLabel'))
    'functional',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:onlyFunctionalMasksLabel'))
    'all',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allMasksLabel'))
    'graphical',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:onlyGraphicalMasksLabel'))
    },'functional',...
    getString(message('RptgenSL:rsl_rpt_mdl_loop_options:lookUnderMasksLabel')),1);


    rptgen.prop(this,'isLibrary',{
    'on',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:includeLibraryLinksLabel'))
    'unique',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:includeUniqueLibraryLinksLabel'))
    'off',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:doNotFollowLibraryLinksLabel'))
    },'off',...
    getString(message('RptgenSL:rsl_rpt_mdl_loop_options:followLibraryLinksLabel')),1);


    p=rptgen.prop(this,'ModelReferenceDepth',rptgen.makeStringType,'0',...
    getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelReferenceLabel')),1);
    p.SetFunction=@setModelReferenceDepth;


    rptgen.prop(this,'IncludeAllVariants','bool',false,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:includeVariantsLabel')),1);


    rptgen.prop(this,'RuntimeMdlName','ustring','','',2);

    if~isempty(this.Method)

        m=find(this.Method,'Name','getDialogSchema');
        if~isempty(m)
            s=m(1).Signature;
            s.varargin='off';
            s.InputTypes={'handle','string'};
            s.OutputTypes={'mxArray'};
        end

        m=find(this.Method,'Name','getDisplayLabel');
        if~isempty(m)
            s=m(1).Signature;
            s.varargin='off';
            s.InputTypes={'handle'};
            s.OutputTypes={'ustring'};
        end
    end

    m=find(this.Method,'Name','getDialogSchema');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','string'};
        s.OutputTypes={'mxArray'};
    end


    function proposedValue=setMdlName(this,proposedValue)

        if strcmp(proposedValue,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentDiagramLabel')))
            proposedValue='$current';

        elseif strcmp(proposedValue,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allOpenModelsLabel')))
            proposedValue='$all';

        elseif strcmp(proposedValue,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:allOpenLibrariesLabel')))
            proposedValue='$alllib';

        elseif strcmp(proposedValue,getString(message('RptgenSL:rsl_rpt_mdl_loop_options:diagramsInCurrentDirectoryLabel')))
            proposedValue='$pwd';
        end

        if strncmp(proposedValue,'$',1)


            oldCurrSys=this.MdlCurrSys;
            newCurrSys=intersect(oldCurrSys,{
'$top'
'$current'
            getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelRootLabel'))
            ['<',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelRootLabel')),'>']
            getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentSystemLabel'))
            ['<',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentSystemLabel')),'>']
            });

            if isempty(newCurrSys)
                this.MdlCurrSys={'$top'};
            elseif(length(newCurrSys)<length(oldCurrSys))
                this.MdlCurrSys=newCurrSys;
            end
        end


        function proposedValue=setMdlCurrSys(~,proposedValue)

            if ischar(proposedValue)
                proposedValue={proposedValue};
            end

            for i=1:length(proposedValue)
                if strcmp(proposedValue{i},getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelRootLabel')))||...
                    strcmp(proposedValue{i},['<',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:modelRootLabel')),'>'])
                    proposedValue{i}='$top';
                elseif strcmp(proposedValue{i},getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentSystemLabel')))||...
                    strcmp(proposedValue{i},['<',getString(message('RptgenSL:rsl_rpt_mdl_loop_options:currentSystemLabel')),'>'])
                    proposedValue{i}='$current';
                end
            end


            function proposedValue=setModelReferenceDepth(~,proposedValue)

                switch proposedValue
                case getString(message('RptgenSL:rsl_rpt_mdl_loop_options:followAllReferencesLabel'))
                    proposedValue='inf';
                case getString(message('RptgenSL:rsl_rpt_mdl_loop_options:doNotFollowReferencesLabel'))
                    proposedValue='0';
                case getString(message('RptgenSL:rsl_rpt_mdl_loop_options:followReferencesInCurrentLabel'))
                    proposedValue='1';
                otherwise
                    proposeValue=rptgen.parseExpressionText(proposedValue);
                    depth=str2double(proposeValue);
                    if~isinf(depth)&&(isnan(depth)||(depth<0)||(int32(depth)~=depth))
                        error(message('RptgenSL:rsl_rpt_mdl_loop_options:stringMustBeIntegerLabel'));
                    end
                end


