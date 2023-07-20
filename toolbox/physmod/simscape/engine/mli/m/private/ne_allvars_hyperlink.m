function msg=ne_allvars_hyperlink(sys,Trow)
    isNodal=cell2mat({sys.VariableData.nodal});
    isInvolvedNonNodal=logical(Trow)&~isNodal;
    isInvolvedNodal=logical(Trow)&isNodal;
    nonNodalBlockNames={sys.VariableData(isInvolvedNonNodal).object};
    nodalBlockNames={sys.VariableData(isInvolvedNodal).object};
    nonNodalPortNames=cellfun(@(x)'',nonNodalBlockNames,'UniformOutput',false);
    nodalPortNames=cellfun(@(x)simscape.internal.containerPathToUserString(ne_get_port(x)),...
    {sys.VariableData(isInvolvedNodal).path},'UniformOutput',false);
    blockNames=[nonNodalBlockNames,nodalBlockNames];
    portNames=[nonNodalPortNames,nodalPortNames];
    allMsg=...
    pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:AllComponentsAndNodalAcross');
    msg=['<a href="matlab:simscape.internal.highlightSLStudio('...
    ,ne_stringify_cell(blockNames),', ',ne_stringify_cell(portNames)...
    ,', true)">',allMsg,sprintf('</a>\n')];
