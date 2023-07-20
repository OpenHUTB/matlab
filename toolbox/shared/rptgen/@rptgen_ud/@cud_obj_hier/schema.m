function schema






    pkg=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cud_obj_hier',pkgRG.findclass('rpt_list'));


    p=rptgen.makeProp(h,'TreeType',{
    'relative',getString(message('rptgen:ru_cud_obj_hier:currentObjLabel'))
    'root',getString(message('rptgen:ru_cud_obj_hier:rootOfCurrentLabel'))
    },'relative',...
    getString(message('rptgen:ru_cud_obj_hier:treeSourceLabel')));


    p=rptgen.makeProp(h,'EmphasizeCurrent','bool',true,...
    getString(message('rptgen:ru_cud_obj_hier:emphasizeCurrentLabel')));


    p=rptgen.makeProp(h,'ParentDepth','int32',10,getString(message('rptgen:ru_cud_obj_hier:parentDepthLabel')));


    p=rptgen.makeProp(h,'ShowSiblings','bool',true,...
    getString(message('rptgen:ru_cud_obj_hier:showSiblingsLabel')));


    p=rptgen.makeProp(h,'ChildDepth','int32',5,getString(message('rptgen:ru_cud_obj_hier:childDepthLabel')));


    pkgRG.findclass('propsrc');
    p=rptgen.makeProp(h,'RuntimePropSrc','rptgen.propsrc',[],...
    'Property source (runtime)',2);

    findclass(findpackage('rpt_xml'),'document');
    p=rptgen.makeProp(h,'RuntimeDocument','rpt_xml.document',[],...
    'Document (parent)',2);


    p=rptgen.makeProp(h,'RuntimeEmphasisNode','mxArray',[],...
    'Node to emphasize (parent)',2);


    rptgen.makeStaticMethods(h,{
    },{
'hierDown'
'hierGetContent'
'hierGetNode'
'hierGetPropSrc'
'hierGetStartPoint'
'hierLeft'
'hierRight'
'hierUp'
'hierGetDialogSchema'
'list_getContent'
    });