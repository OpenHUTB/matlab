function schema






    pkg=findpackage('rptgen');
    h=schema.class(pkg,'rptcomponent',pkg.findclass('DAObject'));


    csDataType='RGComponentOrParsedString';
    if isempty(findtype(csDataType))
        schema.UserType(csDataType,...
        'MATLAB array',...
        @checkComponentOrString);
    end

    p=rptgen.prop(h,'Active','bool',true,...
    getString(message('rptgen:r_rptcomponent:runComponentLabel')));
    p.Visible='off';


    p=rptgen.prop(h,'Tag','ustring','');
    p.Visible='off';

    rptgen.makeStaticMethods(h,{
    },{
'activeHierarchicalChildren'
'addComponent'
'checkComponentTree'
'findDisplayName'
'getChildContentTypes'
'getNumChildren'
'help'
'init'
'runChildren'
'runComponent'
'save'
'status'
'moveLeft'
'moveRight'
'areChildrenOrdered'
'isHierarchical'
'getChildren'
'getHierarchicalChildren'
'getDisplayLabel'
'getDisplayIcon'
'view'
'getPreferredProperties'
'isCopyable'
'isDeletable'
'mcodeConstructor'
    });



    setMethodSignature(h,'areChildrenOrdered',{'handle'},{'bool'});
    setMethodSignature(h,'isHierarchical',{'handle'},{'bool'});
    setMethodSignature(h,'getChildren',{'handle'},{'handle vector'});
    setMethodSignature(h,'getHierarchicalChildren',{'handle'},{'handle vector'});
    setMethodSignature(h,'getDisplayLabel',{'handle'},{'ustring'});
    setMethodSignature(h,'getDisplayIcon',{'handle'},{'ustring'});
    setMethodSignature(h,'getPreferredProperties',{'handle'},{'string vector'});
    setMethodSignature(h,'canAcceptDrop',{'handle','handle vector'},{'bool'});
    setMethodSignature(h,'acceptDrop',{'handle','handle vector'},{'bool'});
    setMethodSignature(h,'getContextMenu',{'handle','handle vector'},{'handle'});
    setMethodSignature(h,'view',{'handle'},{});

    setMethodSignature(h,'updateErrorState',{'handle'},{});
    setMethodSignature(h,'doDelete',{'handle'},{'bool'});
    setMethodSignature(h,'getDialogProxy',{'handle'},{'handle'});











    function setMethodSignature(h,methodName,inputTypes,outputTypes)
        m=find(h.Method,'Name',methodName);
        if~isempty(m)
            s=m.Signature;
            s.varargin='off';
            s.InputTypes=inputTypes;
            s.OutputTypes=outputTypes;
        end


        function ok=checkComponentOrString(inValue)

            ok=ischar(inValue)|isa(inValue,'rptgen.rptcomponent')|isempty(inValue);
