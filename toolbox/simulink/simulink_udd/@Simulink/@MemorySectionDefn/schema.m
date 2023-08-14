function schema()






mlock



    hCreateInPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hCreateInPackage,'BaseMSDefn');


    hThisClass=schema.class(hCreateInPackage,'MemorySectionDefn',hDeriveFromClass);









    hThisProp=schema.prop(hThisClass,'Name','string');%#ok

    hThisProp=schema.prop(hThisClass,'OwnerPackage','string');%#ok

    hThisProp=schema.prop(hThisClass,'Comment','string');
    hThisProp.SetFunction=@setFcn_StringTrim;

    hThisProp=schema.prop(hThisClass,'PragmaPerVar','bool');%#ok

    hThisProp=schema.prop(hThisClass,'PrePragma','string');
    hThisProp.SetFunction=@setFcn_PragmaString;

    hThisProp=schema.prop(hThisClass,'PostPragma','string');
    hThisProp.SetFunction=@setFcn_PragmaString;


    hThisProp=schema.prop(hThisClass,'CommentForUI','string');
    hThisProp.SetFunction=@setFcn_CommentForUI;
    hThisProp.GetFunction=@getFcn_CommentForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'PrePragmaForUI','string');
    hThisProp.SetFunction=@setFcn_PrePragmaForUI;
    hThisProp.GetFunction=@getFcn_PrePragmaForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'PostPragmaForUI','string');
    hThisProp.SetFunction=@setFcn_PostPragmaForUI;
    hThisProp.GetFunction=@getFcn_PostPragmaForUI;
    hThisProp.AccessFlags.Serialize='off';
    hThisProp.AccessFlags.Copy='off';

    hThisProp=schema.prop(hThisClass,'DataUsage','handle');
    hThisProp.GetFunction=@getFcn_DataUsage;
    hThisProp.AccessFlags.AbortSet='off';


    hThisProp=schema.prop(hThisClass,'IsConst','bool');
    hThisProp.GetFunction=@getFcn_IsConst;
    hThisProp.SetFunction=@setFcn_IsConst;
    hThisProp.AccessFlags.AbortSet='off';

    hThisProp=schema.prop(hThisClass,'IsVolatile','bool');%#ok

    hThisProp=schema.prop(hThisClass,'Qualifier','string');
    hThisProp.SetFunction=@setFcn_StringTrim;





    m=schema.method(hThisClass,'getProp');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(hThisClass,'updateRefObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'convert2struct');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'checkCircularReference');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'deepCopy');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle'};


    m=schema.method(hThisClass,'getTabs');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMSPropDetails');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'getMemorySectionDefnForPreview');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle'};

    m=schema.method(hThisClass,'getDefnsForValidation');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'handle','handle'};

    m=schema.method(hThisClass,'isequal');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool'};


    m=schema.method(hThisClass,'isMemSecDefined','static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'string','string'};
    s.OutputTypes={'bool'};







    function actVal=setFcn_StringTrim(hObj,newVal)%#ok
        actVal=strtrim(newVal);



        function actVal=setFcn_PragmaString(hObj,newVal)%#ok
            actVal=strrep(strtrim(newVal),'%<identifier>','$N');



            function newVal=setFcn_CommentForUI(hObj,newVal)
                hObj.Comment=Simulink.CSCUI.prepareUIStringForCode(newVal);



                function actVal=getFcn_CommentForUI(hObj,origVal)%#ok
                    actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.Comment);



                    function newVal=setFcn_PrePragmaForUI(hObj,newVal)
                        hObj.PrePragma=Simulink.CSCUI.prepareUIStringForCode(newVal);



                        function actVal=getFcn_PrePragmaForUI(hObj,origVal)%#ok
                            actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.PrePragma);



                            function newVal=setFcn_PostPragmaForUI(hObj,newVal)
                                hObj.PostPragma=Simulink.CSCUI.prepareUIStringForCode(newVal);



                                function actVal=getFcn_PostPragmaForUI(hObj,origVal)%#ok
                                    actVal=Simulink.CSCUI.prepareCodeStringForUI(hObj.PostPragma);



                                    function value=getFcn_DataUsage(hObj,value)

                                        if isempty(value)
                                            hObj.DataUsage=Simulink.DataUsage;
                                            value=hObj.DataUsage;
                                        end



                                        function value=getFcn_IsConst(hObj,value)

                                            if hObj.DataUsage.IsSignal
                                                value=false;
                                            end



                                            function value=setFcn_IsConst(hObj,value)


                                                if slfeature('SeparateMemorySectionsForParamsAndSignals')~=2
                                                    hObj.DataUsage.IsSignal=~value;
                                                else
                                                    if value
                                                        hObj.DataUsage.IsSignal=false;
                                                    end
                                                end





