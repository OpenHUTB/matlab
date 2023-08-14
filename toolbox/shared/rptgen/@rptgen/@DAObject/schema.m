function schema




    mlock;

    try







        superclassObject=rptgen.getDAOSuperClass();
    catch
        superclassObject={};
    end

    pkg=findpackage('rptgen');
    clsH=schema.class(pkg,...
    'DAObject',...
    superclassObject{:});

    p=rptgen.prop(clsH,'ErrorMessage','ustring','');
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=rptgen.prop(clsH,'Dirty','bool',false);
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=rptgen.prop(clsH,'DirtyListeners','handle vector');
    p.AccessFlags.Serialize='off';
    p.Visible='off';


    m=find(clsH.Method,'Name','buildErrorMessage');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','ustring','bool'};
        s.OutputTypes={'mxArray'};
    end


    m=find(clsH.Method,'Name','getDialogSchema');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle','ustring'};
        s.OutputTypes={'mxArray'};
    end

    m=find(clsH.Method,'Name','view');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle'};
        s.OutputTypes={};
    end

    m=find(clsH.Method,'Name','updateErrorState');
    if~isempty(m)
        s=m.Signature;
        s.varargin='off';
        s.InputTypes={'handle'};
        s.OutputTypes={};
    end

    m=schema.method(clsH,'dlgDatatypeRealPoint');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDatatypeDoubleVector');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDatatypeHandle');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDatatypeStringVector');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDatatypeString');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring','mxArray'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgDatatypeEnum');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','ustring','handle','ustring'};
    s.OutputTypes={};

    m=schema.method(clsH,'dlgFileBrowse');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','ustring','mxArray'};
    s.OutputTypes={};










    mNames=get(clsH.Methods,'Name');
    [~,badIdx]=setdiff(mNames,{
'schema'
'DAObject'
'canCloseDirtyDialog'
'disp'
'dlgMain'
'dlgWidget'
'dlgWidgetInitStruct'
'dlgWidgetStringVector'
'dlgContainer'
'dlgEnable'
'dlgSet'
'dlgText'
'dlgFileBrowse'
'getDialogSchema'
'dlgDatatypeEnum'
'dlgDatatypeHandle'
'dlgDatatypeRealPoint'
'dlgDatatypeDoubleVector'
'dlgDatatypeString'
'dlgDatatypeStringVector'
'dlgShuttlebus'
'onShuttleButtonClicked'
'buildErrorMessage'
'moveUp'
'moveDown'
'moveLeft'
'moveRight'
'updateErrorState'
'setDirty'
'getDirty'
'view'
'viewHelp'
'isCopyable'
'isDeletable'
'doCopy'
'doDelete'
'doClose'
'mcodeConstructor'
'setParent'
'ja'
'CVS'
    });

    if~isempty(badIdx)
        delete(clsH.Methods);
        error(message('rptgen:r_DAObject:unregisteredMethod',clsH.Name));
    end
