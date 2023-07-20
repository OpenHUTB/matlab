function schema




    pkg=findpackage('filterhdlcoder');
    shpkg=findpackage('hdlshared');
    parent=findclass(shpkg,'AbstractHDLTestBench');

    this=schema.class(pkg,'HDLTestbench',parent);

    schema.prop(this,'CommentInfo','mxArray');


    findclass(findpackage('hdlfilter'),'AbstractHDLFilter');
    schema.prop(this,'HDLFilterComp','hdlfilter.AbstractHDLFilter');