function makeStaticMethods(clsH,staticMethods,otherMethods)

















    staticMethods=staticMethods(:);
    for i=1:length(staticMethods)
        schema.method(clsH,staticMethods{i},'static');
    end

    alwaysStaticMethods={
'v1oldname'
'getDescription'
'getAppDataNames'
'getType'
    };
    if~isempty(clsH.Method)
        for i=1:length(alwaysStaticMethods)
            if~isempty(find(clsH.Method,'Name',alwaysStaticMethods{i}))
                schema.method(clsH,alwaysStaticMethods{i},'static');
            end
        end

        m=find(clsH.Method,'Name','getDialogSchema');
        if~isempty(m)
            s=m.Signature;
            s.varargin='off';
            s.InputTypes={'handle','string'};
            s.OutputTypes={'mxArray'};
        end

        m=find(clsH.Method,'Name','updateErrorState');
        if~isempty(m)
            s=m.Signature;
            s.varargin='off';
            s.InputTypes={'handle'};
            s.OutputTypes={};
        end
    end


    if nargin>3
        otherMethods=[otherMethods(:);{
'schema'
        clsH.Name
'CVS'
'ja'
'doc'
'doc_src'
'getName'
'qe_test'
'getOutlineString'
'execute'
'getContentType'
'getParentable'
'checkComponentTree'
'viewHelp'
'v1convert'
'v1convert_att'
'getDialogSchema'
'updateErrorState'
        }];


        mNames=get(clsH.Methods,'Name');
        [~,badIdx]=setdiff(mNames,[staticMethods;alwaysStaticMethods;otherMethods]);
        if~isempty(badIdx)

            delete(clsH.Methods);
            error(message('rptgen:rptgen:unregisteredMethod',clsH.Name));
        end
    end
