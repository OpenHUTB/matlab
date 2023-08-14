function schema





    pkg=findpackage('RptgenML');
    pkgRG=findpackage('rptgen');

    clsH=schema.class(pkg,...
    'ComponentMakerData',...
    pkgRG.findclass('DAObject'));

    p=rptgen.prop(clsH,'PropertyName','string');
    p.Description=getString(message('rptgen:RptgenML_ComponentMakerData:propNameLabel'));
    p.SetFunction={@setSafeString,p.Name};

    p=rptgen.prop(clsH,'DataTypeString','string');
    p.Description=getString(message('rptgen:RptgenML_ComponentMakerData:dataTypeLabel'));
    p.SetFunction={@setDataTypeString};

    p=rptgen.prop(clsH,'IsFactoryDefaultValue','bool',true);

    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.Visible='off';

    p=rptgen.prop(clsH,'FactoryValueString','string');
    p.Description=getString(message('rptgen:RptgenML_ComponentMakerData:defaultValueLabel'));
    p.SetFunction={@setFactoryValueString};

    p=rptgen.prop(clsH,'EnumNames','string vector');

    p=rptgen.prop(clsH,'EnumValues','string vector');
    p.SetFunction={@setSafeStringVector,p.Name};

    p=rptgen.prop(clsH,'Description','string');
    p.Description=getString(message('rptgen:RptgenML_ComponentMakerData:dialogPromptLabel'));


    m=schema.method(clsH,'exploreAction');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(clsH,'areChildrenOrdered');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'isHierarchical');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getHierarchicalChildren');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'handle vector'};

    m=schema.method(clsH,'getDisplayLabel');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getDisplayIcon');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string'};

    m=schema.method(clsH,'getPreferredProperties');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'string vector'};

    m=schema.method(clsH,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};


    m=schema.method(clsH,'canAcceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'acceptDrop');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'bool'};

    m=schema.method(clsH,'getContextMenu');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle vector'};
    s.OutputTypes={'handle'};













    function val=setSafeStringVector(this,val,propName)


        for i=1:length(val)
            val{i}=locWashString(val{i});
        end

        notEmptyIdx=find(~cellfun('isempty',val));
        val=val(notEmptyIdx);

        checkErrors(this,val,propName);



        function storedValue=setSafeString(this,proposedValue,propName)


            storedValue=locWashString(proposedValue);

            checkErrors(this,storedValue,propName);



            function str=locWashString(str)

                absStr=abs(str);

                alphaIdx=(...
                (absStr>=abs('a')&...
                absStr<=abs('z'))|...
                (absStr>=abs('A')&...
                absStr<=abs('Z'))|...
                absStr==abs('_'));
                alphanumIdx=(...
                (absStr>=abs('0')&...
                absStr<=abs('9'))|...
                alphaIdx);


                str(~alphanumIdx)='_';
                str=str(min(find(alphaIdx)):max(find(alphanumIdx)));



                function val=checkErrors(this,val,propName)

                    this.updateErrorState(propName,val);


                    function storedValue=setFactoryValueString(this,proposedValue)

                        storedValue=proposedValue;
                        this.IsFactoryDefaultValue=false;
                        this.updateErrorState('FactoryValueString',proposedValue);


                        function storedValue=setDataTypeString(this,proposedValue)


                            cm=RptgenML.ComponentMaker();
                            defaultProps=cm.getChildren();

                            if(~isempty(defaultProps)&&this.IsFactoryDefaultValue)

                                newDefaultProp=find(defaultProps,'-nocase','DataTypeString',proposedValue);
                                if~isempty(newDefaultProp)
                                    this.FactoryValueString=newDefaultProp(1).FactoryValueString;
                                    this.IsFactoryDefaultValue=true;
                                end
                            end
                            storedValue=proposedValue;

                            this.updateErrorState('DataTypeString',proposedValue);




