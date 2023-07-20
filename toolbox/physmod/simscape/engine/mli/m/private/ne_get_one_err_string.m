function[oneErrString,topologyOnly]=...
    ne_get_one_err_string(err_row,equationData,equationRange,...
    variableData,vars,icrData,icrRange)









    oneErrString='';

    isGeneral=cell2mat({equationData.general});
    isGeneral=isGeneral(:);
    numEqn=length(isGeneral);
    equationNames={equationData.object};
    equationNames=equationNames(:);

    if nargin>5
        isIcr=cell2mat({icrData.initial});
        isGeneral=[isGeneral;isIcr(:)];
        icrNames={icrData.object};
        equationNames=[equationNames;icrNames(:)];
    end





    equationNames=strrep(equationNames,sprintf('\n'),' ');
    isEqnInvolved=err_row'&isGeneral;
    involvedEquations=find(isEqnInvolved);

    if length(involvedEquations)==0
        oneErrString=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:DependentTopology');
        topologyOnly=1;
    else


        topologyOnly=0;
        [involvedEquationNames{1:length(equationNames)}]=deal('');
        involvedEquationNames(involvedEquations)=equationNames(involvedEquations);




        uniqueNames=unique(involvedEquationNames);
        uniqueNames(strcmp(uniqueNames,''))=[];

        hasRangeInfo=(cellfun(@l_eqn_has_info,{equationData.range_num},{equationData.range_start}))';
        if nargin>5
            hasIcrRangeInfo=(cellfun(@l_icr_has_info,{icrData.range_num},{icrData.range_start}))';
            hasRangeInfo=[hasRangeInfo;hasIcrRangeInfo];
        end


        if nargin>3&&~isempty(vars)
            nodals=vars;
            nodals(~cell2mat({variableData.nodal}))=false;

            nodalBlockNames={variableData(nodals).object};
            nodalPortNames=cellfun(@(x)simscape.internal.containerPathToUserString(ne_get_port(x)),...
            {variableData(nodals).path},'UniformOutput',false);
            blockNames=[uniqueNames,nodalBlockNames];
            noPortNames=cellfun(@(x)'',uniqueNames,'UniformOutput',false);
            portNames=[noPortNames,nodalPortNames];
            allComps=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:AllComponents');
            oneErrString=['<a href="matlab:simscape.internal.highlightSLStudio('...
            ,ne_stringify_cell(blockNames),', '...
            ,ne_stringify_cell(portNames)...
            ,', true)">',allComps,sprintf('</a>\n')];
        end
        noInfo=...
        pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:NoLineNumberInfo');
        eqLoc=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:EquationLocation');
        eqLocs=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:EquationLocations');
        for i=1:length(uniqueNames)
            quotedComponentString=sprintf('''%s''',uniqueNames{i});





            componentLinkString=...
            ['<a href="matlab:simscape.internal.highlightSLStudio('...
            ,ne_stringify_cell(uniqueNames(i)),', ',ne_stringify_cell({''})...
            ,')">',quotedComponentString,sprintf('</a>\n')];
            isEqnThisComponent=strcmp(uniqueNames{i},equationNames)&isGeneral&isEqnInvolved;
            pm_assert(nnz(isEqnThisComponent)>0);
            isEqnReportingInfo=isEqnThisComponent&hasRangeInfo;
            eqnsReportingInfo=find(isEqnReportingInfo);
            if isempty(eqnsReportingInfo)
                thisComponentString=componentLinkString;
            elseif length(eqnsReportingInfo)==1
                thisComponentString=[componentLinkString,eqLoc];
            else
                thisComponentString=[componentLinkString,eqLocs];
            end
            for j=1:length(eqnsReportingInfo)
                idx=eqnsReportingInfo(j);
                if idx<=numEqn
                    oneEqnData=equationData(idx);
                    firstRange=equationRange(oneEqnData.range_start+1);
                else
                    oneIcrData=icrData(idx-numEqn);
                    firstRange=icrRange(oneIcrData.range_start+1);
                end
                fileName=firstRange.filename;
                pm_assert(~isempty(fileName));

                quotedFilenameString=['''',fileName,''''];
                if~strcmp(firstRange.type,'NORMAL')
                    oneEqnString=[quotedFilenameString,' ',noInfo];
                else



                    strLineNum=num2str(firstRange.endline);
                    lnStr=pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:Line',...
                    strLineNum);
                    oneEqnString=['<a href="matlab:opentoline(',quotedFilenameString...
                    ,', ',strLineNum,')"> '...
                    ,quotedFilenameString,'</a>'...
                    ,' (',lnStr,')'];
                end
                oneEqnString=[oneEqnString,sprintf('\n')];
                thisComponentString=[thisComponentString,oneEqnString];
            end
            thisComponentString=[thisComponentString,sprintf('\n')];
            oneErrString=[oneErrString,thisComponentString];
        end
    end


    function result=l_eqn_has_info(rangeNum,rangeStart)
        if rangeStart+1>length(equationRange)
            result=false;
        elseif rangeNum==0
            result=false;
        elseif isempty(equationRange(rangeStart+1).filename)
            result=false;
        else
            result=true;
        end
    end

    function result=l_icr_has_info(rangeNum,rangeStart)
        if rangeStart+1>length(icrRange)
            result=false;
        elseif rangeNum==0
            result=false;
        elseif isempty(icrRange(rangeStart+1).filename)
            result=false;
        else
            result=true;
        end
    end


end


