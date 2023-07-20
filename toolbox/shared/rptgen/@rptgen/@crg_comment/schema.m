function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'crg_comment',pkgRG.findclass('rptcomponent'));



    p=rptgen.makeProp(h,'CommentText','ustring','',...
    getString(message('rptgen:r_crg_comment:commentTextLabel')));


    p=rptgen.makeProp(h,'isDisplayComment','bool',false,...
    getString(message('rptgen:r_crg_comment:commentInWindowLabel')));


    p=rptgen.makeProp(h,'CommentStatusLevel',{
    '1',getString(message('rptgen:r_crg_comment:levelOneMessage'))
    '2',getString(message('rptgen:r_crg_comment:levelTwoMessage'))
    '3',getString(message('rptgen:r_crg_comment:levelThreeMessage'))
    '4',getString(message('rptgen:r_crg_comment:levelFourMessage'))
    '5',getString(message('rptgen:r_crg_comment:levelFiveMessage'))
    '6',getString(message('rptgen:r_crg_comment:levelSixMessage'))
    },'4',...
    getString(message('rptgen:r_crg_comment:messagePriorityLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getChildContentTypes'
    });